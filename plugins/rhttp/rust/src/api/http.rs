use flutter_rust_bridge::for_generated::anyhow;
use flutter_rust_bridge::{frb, DartFnFuture};
use futures_util::StreamExt;
use reqwest::header::{HeaderName, HeaderValue};
use reqwest::{Method, Response, Url, Version};
use std::collections::HashMap;
use std::error::Error;
use std::str::FromStr;
use tokio_util::sync::CancellationToken;

use crate::api::client::{ClientSettings, RequestClient};
use crate::api::error::RhttpError;
use crate::api::{error, stream};
use crate::frb_generated::{RustAutoOpaque, StreamSink};

pub struct HttpMethod {
    pub method: String,
}

impl HttpMethod {
    fn to_method(&self) -> Method {
        Method::from_bytes(self.method.as_bytes()).unwrap()
    }
}

pub enum HttpHeaders {
    Map(HashMap<String, String>),
    List(Vec<(String, String)>),
}

pub enum HttpBody {
    Text(String),
    Bytes(Vec<u8>),
    BytesStream,
    Form(HashMap<String, String>),
    Multipart(MultipartPayload),
}

pub struct MultipartPayload {
    pub parts: Vec<(String, MultipartItem)>,
    // https://github.com/seanmonstar/reqwest/issues/2374
    // pub boundary: Option<String>,
}

pub struct MultipartItem {
    pub value: MultipartValue,
    pub file_name: Option<String>,
    pub content_type: Option<String>,
}

pub enum MultipartValue {
    Text(String),
    Bytes(Vec<u8>),
    File(String),
}

#[derive(Clone, Copy)]
pub enum HttpVersionPref {
    Http10,
    Http11,
    Http2,
    Http3,
    All,
}

#[derive(Clone, Copy)]
pub enum HttpExpectBody {
    Text,
    Bytes,
}

pub enum HttpVersion {
    Http09,
    Http10,
    Http11,
    Http2,
    Http3,
    Other,
}

impl HttpVersion {
    fn from_version(version: Version) -> HttpVersion {
        match version {
            Version::HTTP_09 => HttpVersion::Http09,
            Version::HTTP_10 => HttpVersion::Http10,
            Version::HTTP_11 => HttpVersion::Http11,
            Version::HTTP_2 => HttpVersion::Http2,
            Version::HTTP_3 => HttpVersion::Http3,
            _ => HttpVersion::Other,
        }
    }
}

pub struct HttpResponse {
    pub remote_ip: Option<String>,
    pub headers: Vec<(String, String)>,
    pub version: HttpVersion,
    pub status_code: u16,
    pub body: HttpResponseBody,
}

#[derive(Clone, Debug)]
pub enum HttpResponseBody {
    Text(String),
    Bytes(Vec<u8>),
    Stream,
}

// It must be async so that frb provides an async context.
pub async fn register_client(settings: ClientSettings) -> Result<RequestClient, RhttpError> {
    register_client_internal(settings)
}

#[frb(sync)]
pub fn register_client_sync(settings: ClientSettings) -> Result<RequestClient, RhttpError> {
    register_client_internal(settings)
}

fn register_client_internal(settings: ClientSettings) -> Result<RequestClient, RhttpError> {
    let client = RequestClient::new(settings)?;
    Ok(client)
}

pub fn cancel_running_requests(client: &RequestClient) {
    client.cancel_token.cancel();
}

pub async fn make_http_request(
    client: Option<RustAutoOpaque<RequestClient>>,
    settings: Option<ClientSettings>,
    method: HttpMethod,
    url: String,
    query: Option<Vec<(String, String)>>,
    headers: Option<HttpHeaders>,
    body: Option<HttpBody>,
    body_stream: Option<stream::Dart2RustStreamReceiver>,
    expect_body: HttpExpectBody,
    on_cancel_token: impl Fn(CancellationToken) -> DartFnFuture<()>,
    cancelable: bool,
) -> Result<HttpResponse, RhttpError> {
    let cancel_tokens = build_cancel_tokens(client.clone());

    if cancelable {
        on_cancel_token(cancel_tokens.request_cancel_token.clone()).await;
    }

    tokio::select! {
        _ = cancel_tokens.request_cancel_token.cancelled() => Err(RhttpError::RhttpCancelError),
        _ = cancel_tokens.client_cancel_token.cancelled() => Err(RhttpError::RhttpCancelError),
        response = make_http_request_inner(
            client,
            settings,
            method,
            url.to_owned(),
            query,
            headers,
            body,
            body_stream,
            expect_body,
        ) => response,
    }
}

struct RequestCancelTokens {
    request_cancel_token: CancellationToken,
    client_cancel_token: CancellationToken,
}

fn build_cancel_tokens(client: Option<RustAutoOpaque<RequestClient>>) -> RequestCancelTokens {
    let client_cancel_token = match client {
        Some(client) => Some(client.try_read().unwrap().cancel_token.clone()),
        None => None,
    }
    .unwrap_or_else(|| CancellationToken::new());

    RequestCancelTokens {
        request_cancel_token: CancellationToken::new(),
        client_cancel_token,
    }
}

async fn make_http_request_inner(
    client: Option<RustAutoOpaque<RequestClient>>,
    settings: Option<ClientSettings>,
    method: HttpMethod,
    url: String,
    query: Option<Vec<(String, String)>>,
    headers: Option<HttpHeaders>,
    body: Option<HttpBody>,
    body_stream: Option<stream::Dart2RustStreamReceiver>,
    expect_body: HttpExpectBody,
) -> Result<HttpResponse, RhttpError> {
    let response = make_http_request_helper(
        client,
        settings,
        method,
        url,
        query,
        headers,
        body,
        body_stream,
        Some(expect_body),
    )
    .await?;

    Ok(HttpResponse {
        remote_ip: extract_ip(&response),
        headers: header_to_vec(response.headers()),
        version: HttpVersion::from_version(response.version()),
        status_code: response.status().as_u16(),
        body: match expect_body {
            HttpExpectBody::Text => HttpResponseBody::Text(
                response
                    .text()
                    .await
                    .map_err(|e| RhttpError::RhttpUnknownError(e.to_string()))?,
            ),
            HttpExpectBody::Bytes => HttpResponseBody::Bytes(
                response
                    .bytes()
                    .await
                    .map_err(|e| RhttpError::RhttpUnknownError(e.to_string()))?
                    .to_vec(),
            ),
        },
    })
}

pub async fn make_http_request_receive_stream(
    client: Option<RustAutoOpaque<RequestClient>>,
    settings: Option<ClientSettings>,
    method: HttpMethod,
    url: String,
    query: Option<Vec<(String, String)>>,
    headers: Option<HttpHeaders>,
    body: Option<HttpBody>,
    body_stream: Option<stream::Dart2RustStreamReceiver>,
    stream_sink: StreamSink<Vec<u8>>,
    on_response: impl Fn(HttpResponse) -> DartFnFuture<()>,
    on_error: impl Fn(RhttpError) -> DartFnFuture<()>,
    on_cancel_token: impl Fn(CancellationToken) -> DartFnFuture<()>,
    cancelable: bool,
) {
    let cancel_tokens = build_cancel_tokens(client.clone());

    if cancelable {
        on_cancel_token(cancel_tokens.request_cancel_token.clone()).await;
    }

    tokio::select! {
        _ = cancel_tokens.request_cancel_token.cancelled() => {
            let _ = stream_sink.add_error(anyhow::anyhow!(error::STREAM_CANCEL_ERROR));
            on_error(RhttpError::RhttpCancelError).await;
        },
        _ = cancel_tokens.client_cancel_token.cancelled() => {
            let _ = stream_sink.add_error(anyhow::anyhow!(error::STREAM_CANCEL_ERROR));
            on_error(RhttpError::RhttpCancelError).await;
        },
        _ = make_http_request_receive_stream_inner(
            client,
            settings,
            method,
            url.to_owned(),
            query,
            headers,
            body,
            body_stream,
            stream_sink.clone(),
            on_response,
            &on_error,
        ) => {},
    }
}

async fn make_http_request_receive_stream_inner(
    client: Option<RustAutoOpaque<RequestClient>>,
    settings: Option<ClientSettings>,
    method: HttpMethod,
    url: String,
    query: Option<Vec<(String, String)>>,
    headers: Option<HttpHeaders>,
    body: Option<HttpBody>,
    body_stream: Option<stream::Dart2RustStreamReceiver>,
    stream_sink: StreamSink<Vec<u8>>,
    on_response: impl Fn(HttpResponse) -> DartFnFuture<()>,
    on_error: &impl Fn(RhttpError) -> DartFnFuture<()>,
) {
    let response = make_http_request_helper(
        client,
        settings,
        method,
        url,
        query,
        headers,
        body,
        body_stream,
        None,
    )
    .await;

    let response: Response = match response {
        Ok(res) => res,
        Err(e) => {
            on_error(e.clone()).await;
            return;
        }
    };

    let http_response = HttpResponse {
        remote_ip: extract_ip(&response),
        headers: header_to_vec(response.headers()),
        version: HttpVersion::from_version(response.version()),
        status_code: response.status().as_u16(),
        body: HttpResponseBody::Stream,
    };

    on_response(http_response).await;

    let mut stream = response.bytes_stream();

    while let Some(chunk) = stream.next().await {
        let chunk = chunk.inspect_err(|e| {
            let _ = stream_sink.add_error(anyhow::anyhow!(e.to_string()));
        });

        if chunk.is_err() {
            return;
        }

        let result = stream_sink.add(chunk.unwrap().to_vec()).inspect_err(|e| {
            let _ = stream_sink.add_error(anyhow::anyhow!(e.to_string()));
        });

        if result.is_err() {
            return;
        }
    }
}

/// This function is used to make an HTTP request without any response handling.
async fn make_http_request_helper(
    client: Option<RustAutoOpaque<RequestClient>>,
    settings: Option<ClientSettings>,
    method: HttpMethod,
    url: String,
    query: Option<Vec<(String, String)>>,
    headers: Option<HttpHeaders>,
    body: Option<HttpBody>,
    body_stream: Option<stream::Dart2RustStreamReceiver>,
    expect_body: Option<HttpExpectBody>,
) -> Result<Response, RhttpError> {
    let client: RequestClient = match client {
        Some(client) => client.try_read().unwrap().clone(),
        None => match settings {
            Some(settings) => RequestClient::new(settings)
                .map_err(|e| RhttpError::RhttpUnknownError(e.to_string()))?,
            None => RequestClient::new_default(),
        },
    };
    let parsed_url = Url::parse(&url).map_err(|e| RhttpError::RhttpUnknownError(e.to_string()))?;
    let effective_client = client.client_for_url(&parsed_url).await?;

    let request = {
        let mut request = effective_client.request(method.to_method(), parsed_url);

        request = match client.http_version_pref {
            HttpVersionPref::Http10 => request.version(Version::HTTP_10),
            HttpVersionPref::Http11 => request.version(Version::HTTP_11),
            HttpVersionPref::Http2 => request.version(Version::HTTP_2),
            HttpVersionPref::Http3 => request.version(Version::HTTP_3),
            HttpVersionPref::All => request,
        };

        if let Some(query) = query {
            request = request.query(&query);
        }

        match headers {
            Some(HttpHeaders::Map(map)) => {
                for (k, v) in map {
                    let header_name = HeaderName::from_str(&k)
                        .map_err(|e| RhttpError::RhttpUnknownError(e.to_string()))?;
                    let header_value = HeaderValue::from_str(&v)
                        .map_err(|e| RhttpError::RhttpUnknownError(e.to_string()))?;
                    request = request.header(header_name, header_value);
                }
            }
            Some(HttpHeaders::List(list)) => {
                for (k, v) in list {
                    let header_name = HeaderName::from_str(&k)
                        .map_err(|e| RhttpError::RhttpUnknownError(e.to_string()))?;
                    let header_value = HeaderValue::from_str(&v)
                        .map_err(|e| RhttpError::RhttpUnknownError(e.to_string()))?;
                    request = request.header(header_name, header_value);
                }
            }
            None => (),
        };

        request = match body {
            Some(HttpBody::Text(text)) => request.body(text),
            Some(HttpBody::Bytes(bytes)) => request.body(bytes),
            Some(HttpBody::BytesStream) => {
                let stream = body_stream
                    .expect("body_stream should exist for HttpBody::BytesStream")
                    .receiver
                    .map(|v| Ok::<Vec<u8>, RhttpError>(v));

                let body = reqwest::Body::wrap_stream(stream);
                request.body(body)
            }
            Some(HttpBody::Form(form)) => request.form(&form),
            Some(HttpBody::Multipart(body)) => {
                let mut form = reqwest::multipart::Form::new();
                for (k, v) in body.parts {
                    let mut part = match v.value {
                        MultipartValue::Text(text) => reqwest::multipart::Part::text(text),
                        MultipartValue::Bytes(bytes) => reqwest::multipart::Part::bytes(bytes),
                        MultipartValue::File(file) => {
                            let file = tokio::fs::File::open(file).await.map_err(|_| {
                                RhttpError::RhttpUnknownError("Failed to open file".to_string())
                            })?;
                            reqwest::multipart::Part::stream(reqwest::Body::wrap_stream(
                                tokio_util::io::ReaderStream::new(file),
                            ))
                        }
                    };

                    if let Some(file_name) = v.file_name {
                        part = part.file_name(file_name);
                    }

                    if let Some(content_type) = v.content_type {
                        part = part
                            .mime_str(&content_type)
                            .map_err(|e| RhttpError::RhttpUnknownError(e.to_string()))?;
                    }

                    form = form.part(k, part);
                }

                request.multipart(form)
            }
            None => request,
        };

        request
            .build()
            .map_err(|e| RhttpError::RhttpUnknownError(e.to_string()))?
    };

    let response = effective_client.execute(request).await.map_err(|e| {
        if e.is_redirect() {
            RhttpError::RhttpRedirectError
        } else if e.is_timeout() {
            RhttpError::RhttpTimeoutError
        } else {
            // We use the debug string because it contains more information
            let inner = e.source();
            let is_cert_error = match inner {
                // TODO: This is a hacky way to check if the error is a certificate error
                Some(inner) => format!("{:?}", inner).contains("InvalidCertificate"),
                None => false,
            };

            if is_cert_error {
                RhttpError::RhttpInvalidCertificateError(format!("{:?}", inner.unwrap()))
            } else if e.is_connect() {
                RhttpError::RhttpConnectionError(format!("{:?}", inner.unwrap()))
            } else {
                RhttpError::RhttpUnknownError(match inner {
                    Some(inner) => format!("{inner:?}"),
                    None => format!("{e:?}"),
                })
            }
        }
    })?;

    if client.throw_on_status_code {
        let status = response.status();
        if status.is_client_error() || status.is_server_error() {
            return Err(RhttpError::RhttpStatusCodeError(
                response.status().as_u16(),
                header_to_vec(response.headers()),
                match expect_body {
                    Some(HttpExpectBody::Text) => HttpResponseBody::Text(
                        response
                            .text()
                            .await
                            .map_err(|e| RhttpError::RhttpUnknownError(e.to_string()))?,
                    ),
                    Some(HttpExpectBody::Bytes) => HttpResponseBody::Bytes(
                        response
                            .bytes()
                            .await
                            .map_err(|e| RhttpError::RhttpUnknownError(e.to_string()))?
                            .to_vec(),
                    ),
                    _ => HttpResponseBody::Stream,
                },
            ));
        }
    }

    Ok(response)
}

fn header_to_vec(headers: &reqwest::header::HeaderMap) -> Vec<(String, String)> {
    headers
        .iter()
        .filter_map(|(k, v)| match v.to_str() {
            Ok(v_str) => Some((k.as_str().to_string(), v_str.to_string())),
            Err(_) => None,
        })
        .collect()
}

pub fn cancel_request(token: &CancellationToken) {
    token.cancel();
}

fn extract_ip(response: &Response) -> Option<String> {
    response.remote_addr().map(|addr| addr.ip().to_string())
}
