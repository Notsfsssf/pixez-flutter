use crate::api::error::RhttpError;
use crate::api::http::HttpVersionPref;
use crate::utils::socket_addr::SocketAddrDigester;
use base64::Engine;
use chrono::Duration;
use flutter_rust_bridge::{frb, DartFnFuture};
use reqwest::cookie::Jar;
use reqwest::dns::{Addrs, Name, Resolve, Resolving};
use reqwest::{tls, Certificate, Url};
use rustls::client::danger::{HandshakeSignatureValid, ServerCertVerified, ServerCertVerifier};
use rustls::client::{EchConfig, EchMode};
use rustls::crypto::aws_lc_rs::hpke::ALL_SUPPORTED_SUITES;
use rustls::pki_types::pem::PemObject;
use rustls::pki_types::{CertificateDer, EchConfigListBytes, PrivateKeyDer, ServerName, UnixTime};
use rustls::{DigitallySignedStruct, Error as TlsError, RootCertStore, SignatureScheme};
use serde_json::Value;
use std::collections::HashMap;
use std::net::{IpAddr, SocketAddr};
use std::str::FromStr;
use std::sync::Arc;
use tokio::sync::RwLock;
pub use tokio_util::sync::CancellationToken;

const ALIDNS_RESOLVE_ENDPOINT: &str = "https://dns.alidns.com/resolve";
const APP_API_PIXIV_NET_HOST: &str = "app-api.pixiv.net";
const APP_API_PIXIV_NET_ECH_BOOTSTRAP_HOST: &str = "cloudflare-ech.com";

#[derive(Clone)]
pub struct ClientSettings {
    pub cookie_settings: Option<CookieSettings>,
    pub http_version_pref: HttpVersionPref,
    pub timeout_settings: Option<TimeoutSettings>,
    pub throw_on_status_code: bool,
    pub enable_ech: bool,
    pub proxy_settings: Option<ProxySettings>,
    pub redirect_settings: Option<RedirectSettings>,
    pub tls_settings: Option<TlsSettings>,
    pub dns_settings: Option<DnsSettings>,
    pub user_agent: Option<String>,
}

#[derive(Clone)]
pub struct CookieSettings {
    pub store_cookies: bool,
}

#[derive(Clone)]
pub enum ProxySettings {
    NoProxy,
    CustomProxyList(Vec<CustomProxy>),
}

#[derive(Clone)]
pub struct CustomProxy {
    pub url: String,
    pub condition: ProxyCondition,
}

#[derive(Clone)]
pub enum ProxyCondition {
    Http,
    Https,
    All,
}

#[derive(Clone)]
pub enum RedirectSettings {
    NoRedirect,
    LimitedRedirects(i32),
}

#[derive(Clone)]
pub struct TimeoutSettings {
    pub timeout: Option<Duration>,
    pub connect_timeout: Option<Duration>,
    pub keep_alive_timeout: Option<Duration>,
    pub keep_alive_ping: Option<Duration>,
}

#[derive(Clone)]
pub struct TlsSettings {
    pub trust_root_certificates: bool,
    pub trusted_root_certificates: Vec<Vec<u8>>,
    pub verify_certificates: bool,
    pub client_certificate: Option<ClientCertificate>,
    pub min_tls_version: Option<TlsVersion>,
    pub max_tls_version: Option<TlsVersion>,
    pub sni: bool,
}

#[derive(Clone)]
pub enum DnsSettings {
    StaticDns(StaticDnsSettings),
    DynamicDns(DynamicDnsSettings),
}

#[derive(Clone)]
pub struct StaticDnsSettings {
    pub overrides: HashMap<String, Vec<String>>,
    pub fallback: Option<String>,
}

#[derive(Clone)]
pub struct DynamicDnsSettings {
    /// A function that takes a hostname and returns a future that resolves to an IP address.
    resolver: Arc<dyn Fn(String) -> DartFnFuture<Vec<String>> + 'static + Send + Sync>,
}

#[derive(Clone)]
pub struct ClientCertificate {
    pub certificate: Vec<u8>,
    pub private_key: Vec<u8>,
}

#[derive(Clone, Copy)]
pub enum TlsVersion {
    Tls1_2,
    Tls1_3,
}

impl Default for ClientSettings {
    fn default() -> Self {
        ClientSettings {
            cookie_settings: None,
            http_version_pref: HttpVersionPref::All,
            timeout_settings: None,
            throw_on_status_code: true,
            enable_ech: false,
            proxy_settings: None,
            redirect_settings: None,
            tls_settings: None,
            dns_settings: None,
            user_agent: None,
        }
    }
}

#[derive(Clone)]
pub struct RequestClient {
    pub(crate) client: reqwest::Client,
    pub(crate) settings: ClientSettings,
    pub(crate) http_version_pref: HttpVersionPref,
    pub(crate) throw_on_status_code: bool,

    /// A token that can be used to cancel all requests made by this client.
    pub(crate) cancel_token: CancellationToken,

    runtime: Arc<ClientRuntime>,
}

struct ClientRuntime {
    cookie_jar: Option<Arc<Jar>>,
    ech: Arc<EchTransport>,
    ech_clients: RwLock<HashMap<String, Option<reqwest::Client>>>,
}

impl RequestClient {
    pub(crate) fn new_default() -> Self {
        create_client(ClientSettings::default()).unwrap()
    }

    pub(crate) fn new(settings: ClientSettings) -> Result<RequestClient, RhttpError> {
        create_client(settings)
    }

    pub(crate) async fn client_for_url(&self, url: &Url) -> Result<reqwest::Client, RhttpError> {
        if !self.should_try_ech(url) {
            return Ok(self.client.clone());
        }

        let host = url
            .host_str()
            .map(str::to_ascii_lowercase)
            .unwrap_or_default();

        if let Some(cached) = self.runtime.ech_clients.read().await.get(&host).cloned() {
            return Ok(cached.unwrap_or_else(|| self.client.clone()));
        }

        let ech_config = match self.runtime.ech.lookup_ech_config(&host).await {
            Ok(ech_config) => ech_config,
            Err(_) => return Ok(self.client.clone()),
        };

        let ech_client = match ech_config {
            Some(ech_config) => match build_reqwest_client(
                &self.settings,
                &self.runtime,
                Some(ech_config.as_slice()),
            ) {
                Ok(client) => Some(client),
                Err(_) => return Ok(self.client.clone()),
            },
            None => None,
        };

        self.runtime
            .ech_clients
            .write()
            .await
            .insert(host, ech_client.clone());

        Ok(ech_client.unwrap_or_else(|| self.client.clone()))
    }

    fn should_try_ech(&self, url: &Url) -> bool {
        if !self.settings.enable_ech {
            return false;
        }

        if url.scheme() != "https" {
            return false;
        }

        let Some(host) = url.host_str() else {
            return false;
        };

        if !host.eq_ignore_ascii_case(APP_API_PIXIV_NET_HOST) {
            return false;
        }

        if host.parse::<IpAddr>().is_ok() {
            return false;
        }

        match self.settings.tls_settings.as_ref() {
            Some(settings) => {
                settings.sni && !matches!(settings.max_tls_version, Some(TlsVersion::Tls1_2))
            }
            None => true,
        }
    }
}

fn create_client(settings: ClientSettings) -> Result<RequestClient, RhttpError> {
    let runtime = Arc::new(ClientRuntime {
        cookie_jar: settings
            .cookie_settings
            .as_ref()
            .filter(|settings| settings.store_cookies)
            .map(|_| Arc::new(Jar::default())),
        ech: Arc::new(EchTransport::new()?),
        ech_clients: RwLock::new(HashMap::new()),
    });

    let client = build_reqwest_client(&settings, &runtime, None)?;

    Ok(RequestClient {
        client,
        settings: settings.clone(),
        http_version_pref: settings.http_version_pref,
        throw_on_status_code: settings.throw_on_status_code,
        cancel_token: CancellationToken::new(),
        runtime,
    })
}

fn build_reqwest_client(
    settings: &ClientSettings,
    runtime: &Arc<ClientRuntime>,
    ech_config_list: Option<&[u8]>,
) -> Result<reqwest::Client, RhttpError> {
    let mut client = reqwest::Client::builder();

    if let Some(proxy_settings) = settings.proxy_settings.as_ref() {
        match proxy_settings {
            ProxySettings::NoProxy => client = client.no_proxy(),
            ProxySettings::CustomProxyList(proxies) => {
                for proxy in proxies {
                    let proxy = match proxy.condition {
                        ProxyCondition::Http => reqwest::Proxy::http(&proxy.url),
                        ProxyCondition::Https => reqwest::Proxy::https(&proxy.url),
                        ProxyCondition::All => reqwest::Proxy::all(&proxy.url),
                    }
                    .map_err(|e| {
                        RhttpError::RhttpUnknownError(format!("Error creating proxy: {e:?}"))
                    })?;
                    client = client.proxy(proxy);
                }
            }
        }
    }

    if let Some(cookie_jar) = runtime.cookie_jar.as_ref() {
        client = client.cookie_provider(cookie_jar.clone());
    }

    if let Some(redirect_settings) = settings.redirect_settings.as_ref() {
        client = match redirect_settings {
            RedirectSettings::NoRedirect => client.redirect(reqwest::redirect::Policy::none()),
            RedirectSettings::LimitedRedirects(max_redirects) => {
                client.redirect(reqwest::redirect::Policy::limited(*max_redirects as usize))
            }
        };
    }

    if let Some(timeout_settings) = settings.timeout_settings.as_ref() {
        if let Some(timeout) = timeout_settings.timeout {
            client = client.timeout(
                timeout
                    .to_std()
                    .map_err(|e| RhttpError::RhttpUnknownError(e.to_string()))?,
            );
        }

        if let Some(timeout) = timeout_settings.connect_timeout {
            client = client.connect_timeout(
                timeout
                    .to_std()
                    .map_err(|e| RhttpError::RhttpUnknownError(e.to_string()))?,
            );
        }

        if let Some(keep_alive_timeout) = timeout_settings.keep_alive_timeout {
            let timeout = keep_alive_timeout
                .to_std()
                .map_err(|e| RhttpError::RhttpUnknownError(e.to_string()))?;
            if timeout.as_millis() > 0 {
                client = client.tcp_keepalive(timeout);
                client = client.http2_keep_alive_while_idle(true);
                client = client.http2_keep_alive_timeout(timeout);
            }
        }

        if let Some(keep_alive_ping) = timeout_settings.keep_alive_ping {
            client = client.http2_keep_alive_interval(
                keep_alive_ping
                    .to_std()
                    .map_err(|e| RhttpError::RhttpUnknownError(e.to_string()))?,
            );
        }
    }

    client = match ech_config_list {
        Some(ech_config_list) => {
            client.tls_backend_preconfigured(build_ech_tls_config(settings, ech_config_list)?)
        }
        None => apply_reqwest_tls_settings(client, settings.tls_settings.as_ref())?,
    };

    client = match settings.http_version_pref {
        HttpVersionPref::Http10 | HttpVersionPref::Http11 => client.http1_only(),
        HttpVersionPref::Http2 => client.http2_prior_knowledge(),
        HttpVersionPref::Http3 => client.http3_prior_knowledge(),
        HttpVersionPref::All => client,
    };

    client = apply_dns_settings(client, settings.dns_settings.as_ref())?;

    if let Some(user_agent) = settings.user_agent.as_ref() {
        client = client.user_agent(user_agent.clone());
    }

    client
        .build()
        .map_err(|e| RhttpError::RhttpUnknownError(format!("{e:?}")))
}

fn apply_reqwest_tls_settings(
    mut client: reqwest::ClientBuilder,
    tls_settings: Option<&TlsSettings>,
) -> Result<reqwest::ClientBuilder, RhttpError> {
    let Some(tls_settings) = tls_settings else {
        return Ok(client);
    };

    let root_certificates = tls_settings
        .trusted_root_certificates
        .iter()
        .map(|cert| {
            Certificate::from_pem(cert).map_err(|e| {
                RhttpError::RhttpUnknownError(format!("Error adding trusted certificate: {e:?}"))
            })
        })
        .collect::<Result<Vec<_>, _>>()?;

    if !tls_settings.trust_root_certificates {
        client = client.tls_certs_only(root_certificates);
    } else if !root_certificates.is_empty() {
        client = client.tls_certs_merge(root_certificates);
    }

    if tls_settings.verify_certificates {
        client = client.tls_danger_accept_invalid_certs(false);
    } else {
        client = client.tls_danger_accept_invalid_certs(true);
    }

    if let Some(client_certificate) = tls_settings.client_certificate.as_ref() {
        let identity = &[
            client_certificate.certificate.as_slice(),
            "\n".as_bytes(),
            client_certificate.private_key.as_slice(),
        ]
        .concat();

        client = client.identity(
            reqwest::Identity::from_pem(identity)
                .map_err(|e| RhttpError::RhttpUnknownError(format!("{e:?}")))?,
        );
    }

    if let Some(min_tls_version) = tls_settings.min_tls_version {
        client = client.min_tls_version(match min_tls_version {
            TlsVersion::Tls1_2 => tls::Version::TLS_1_2,
            TlsVersion::Tls1_3 => tls::Version::TLS_1_3,
        });
    }

    if let Some(max_tls_version) = tls_settings.max_tls_version {
        client = client.max_tls_version(match max_tls_version {
            TlsVersion::Tls1_2 => tls::Version::TLS_1_2,
            TlsVersion::Tls1_3 => tls::Version::TLS_1_3,
        });
    }

    Ok(client.tls_sni(tls_settings.sni))
}

fn build_ech_tls_config(
    settings: &ClientSettings,
    ech_config_list: &[u8],
) -> Result<rustls::ClientConfig, RhttpError> {
    let tls_settings = settings.tls_settings.as_ref();

    if matches!(
        tls_settings.and_then(|settings| settings.max_tls_version),
        Some(TlsVersion::Tls1_2)
    ) {
        return Err(RhttpError::RhttpUnknownError(
            "ECH requires TLS 1.3 support".to_string(),
        ));
    }

    if matches!(tls_settings, Some(settings) if !settings.sni) {
        return Err(RhttpError::RhttpUnknownError(
            "ECH requires SNI to be enabled".to_string(),
        ));
    }

    let provider = rustls::crypto::CryptoProvider::get_default()
        .cloned()
        .unwrap_or_else(|| Arc::new(rustls::crypto::aws_lc_rs::default_provider()));

    let ech_config = EchConfig::new(
        EchConfigListBytes::from(ech_config_list.to_vec()),
        ALL_SUPPORTED_SUITES,
    )
    .map_err(|e| RhttpError::RhttpUnknownError(format!("Invalid ECH config: {e:?}")))?;

    let config_builder = rustls::ClientConfig::builder_with_provider(provider.clone())
        .with_ech(EchMode::from(ech_config))
        .map_err(|e| RhttpError::RhttpUnknownError(format!("Invalid ECH setup: {e:?}")))?;

    let config_builder = match tls_settings {
        Some(tls_settings) if !tls_settings.verify_certificates => config_builder
            .dangerous()
            .with_custom_certificate_verifier(Arc::new(NoVerifier)),
        Some(tls_settings) if !tls_settings.trust_root_certificates => config_builder
            .with_root_certificates(build_root_store(&tls_settings.trusted_root_certificates)?),
        Some(tls_settings)
            if !tls_settings.trusted_root_certificates.is_empty()
                && tls_settings.trust_root_certificates =>
        {
            #[cfg(any(all(unix, not(target_os = "android")), target_os = "windows"))]
            {
                let verifier = rustls_platform_verifier::Verifier::new_with_extra_roots(
                    collect_root_cert_ders(&tls_settings.trusted_root_certificates)?,
                    provider.clone(),
                )
                .map_err(|e| RhttpError::RhttpUnknownError(format!("{e:?}")))?;

                config_builder
                    .dangerous()
                    .with_custom_certificate_verifier(Arc::new(verifier))
            }

            #[cfg(not(any(all(unix, not(target_os = "android")), target_os = "windows")))]
            {
                return Err(RhttpError::RhttpUnknownError(
                    "ECH with extra system roots is unsupported on this target".to_string(),
                ));
            }
        }
        _ => {
            let verifier = rustls_platform_verifier::Verifier::new(provider.clone())
                .map_err(|e| RhttpError::RhttpUnknownError(format!("{e:?}")))?;

            config_builder
                .dangerous()
                .with_custom_certificate_verifier(Arc::new(verifier))
        }
    };

    let mut tls = if let Some(client_certificate) =
        tls_settings.and_then(|settings| settings.client_certificate.as_ref())
    {
        let cert_chain = collect_pem_certificates(&client_certificate.certificate)?;
        let private_key = parse_private_key(&client_certificate.private_key)?;

        config_builder
            .with_client_auth_cert(cert_chain, private_key)
            .map_err(|e| RhttpError::RhttpUnknownError(format!("{e:?}")))?
    } else {
        config_builder.with_no_client_auth()
    };

    tls.enable_sni = tls_settings.map(|settings| settings.sni).unwrap_or(true);

    match settings.http_version_pref {
        HttpVersionPref::Http10 | HttpVersionPref::Http11 => {
            tls.alpn_protocols = vec!["http/1.1".into()];
        }
        HttpVersionPref::Http2 => {
            tls.alpn_protocols = vec!["h2".into()];
        }
        HttpVersionPref::Http3 => {}
        HttpVersionPref::All => {
            tls.alpn_protocols = vec!["h2".into(), "http/1.1".into()];
        }
    }

    Ok(tls)
}

fn apply_dns_settings(
    mut client: reqwest::ClientBuilder,
    dns_settings: Option<&DnsSettings>,
) -> Result<reqwest::ClientBuilder, RhttpError> {
    match dns_settings {
        Some(DnsSettings::StaticDns(settings)) => {
            if let Some(fallback) = settings.fallback.as_ref() {
                client = client.dns_resolver(Arc::new(StaticResolver {
                    address: SocketAddr::from_str(fallback.clone().digest_ip().as_str())
                        .map_err(|e| RhttpError::RhttpUnknownError(format!("{e:?}")))?,
                }));
            }

            for (hostname, ips) in &settings.overrides {
                let mut err: Option<String> = None;
                let resolved_ips = ips
                    .iter()
                    .cloned()
                    .map(|ip| {
                        let ip_digested = ip.digest_ip();
                        SocketAddr::from_str(ip_digested.as_str()).map_err(|e| {
                            err = Some(format!("Invalid IP address: {ip_digested}. {e:?}"));
                            RhttpError::RhttpUnknownError(e.to_string())
                        })
                    })
                    .filter_map(Result::ok)
                    .collect::<Vec<SocketAddr>>();

                if let Some(error) = err {
                    return Err(RhttpError::RhttpUnknownError(error));
                }

                client = client.resolve_to_addrs(hostname, resolved_ips.as_slice());
            }
        }
        Some(DnsSettings::DynamicDns(settings)) => {
            client = client.dns_resolver(Arc::new(DynamicResolver {
                resolver: settings.resolver.clone(),
            }));
        }
        None => {}
    }

    Ok(client)
}

fn collect_pem_certificates(
    certificate_pem: &[u8],
) -> Result<Vec<CertificateDer<'static>>, RhttpError> {
    let certificates = CertificateDer::pem_slice_iter(certificate_pem)
        .map(|result| {
            result
                .map(|cert| cert.into_owned())
                .map_err(|_| RhttpError::RhttpUnknownError("Invalid PEM certificate".to_string()))
        })
        .collect::<Result<Vec<_>, _>>()?;

    if certificates.is_empty() {
        return Err(RhttpError::RhttpUnknownError(
            "Certificate chain is empty".to_string(),
        ));
    }

    Ok(certificates)
}

fn collect_root_cert_ders(
    trusted_root_certificates: &[Vec<u8>],
) -> Result<Vec<CertificateDer<'static>>, RhttpError> {
    let mut certificates = Vec::new();
    for cert in trusted_root_certificates {
        certificates.extend(collect_pem_certificates(cert)?);
    }
    Ok(certificates)
}

fn build_root_store(trusted_root_certificates: &[Vec<u8>]) -> Result<RootCertStore, RhttpError> {
    let mut root_store = RootCertStore::empty();
    for cert in collect_root_cert_ders(trusted_root_certificates)? {
        root_store
            .add(cert)
            .map_err(|e| RhttpError::RhttpUnknownError(format!("{e:?}")))?;
    }
    Ok(root_store)
}

fn parse_private_key(private_key: &[u8]) -> Result<PrivateKeyDer<'static>, RhttpError> {
    PrivateKeyDer::from_pem_slice(private_key)
        .or_else(|_| {
            PrivateKeyDer::try_from(private_key)
                .map(|key| key.clone_key())
                .map_err(|_| "Invalid private key".to_string())
        })
        .map_err(|e| RhttpError::RhttpUnknownError(format!("{e:?}")))
}

struct StaticResolver {
    address: SocketAddr,
}

impl Resolve for StaticResolver {
    fn resolve(&self, _: Name) -> Resolving {
        let addrs: Addrs = Box::new(vec![self.address].into_iter());
        Box::pin(futures_util::future::ready(Ok(addrs)))
    }
}

struct DynamicResolver {
    resolver: Arc<dyn Fn(String) -> DartFnFuture<Vec<String>> + 'static + Send + Sync>,
}

impl Resolve for DynamicResolver {
    fn resolve(&self, name: Name) -> Resolving {
        let resolver = self.resolver.clone();
        Box::pin(async move {
            let ip = resolver(name.as_str().to_owned()).await;
            let ip = ip
                .into_iter()
                .map(|ip| {
                    let ip_digested = ip.digest_ip();
                    SocketAddr::from_str(ip_digested.as_str()).map_err(|e| {
                        RhttpError::RhttpUnknownError(format!(
                            "Invalid IP address: {ip_digested}. {e:?}"
                        ))
                    })
                })
                .filter_map(Result::ok)
                .collect::<Vec<SocketAddr>>();

            let addrs: Addrs = Box::new(ip.into_iter());
            Ok(addrs)
        })
    }
}

struct EchTransport {
    ech_endpoint: Url,
    client: reqwest::Client,
}

impl EchTransport {
    fn new() -> Result<Self, RhttpError> {
        let ech_endpoint = Url::parse(ALIDNS_RESOLVE_ENDPOINT)
            .map_err(|e| RhttpError::RhttpUnknownError(e.to_string()))?;
        let client = reqwest::Client::builder()
            .no_proxy()
            .redirect(reqwest::redirect::Policy::none())
            .build()
            .map_err(|e| RhttpError::RhttpUnknownError(e.to_string()))?;

        Ok(Self {
            ech_endpoint,
            client,
        })
    }

    async fn lookup_ech_config(&self, host: &str) -> Result<Option<Vec<u8>>, RhttpError> {
        if host.eq_ignore_ascii_case(APP_API_PIXIV_NET_HOST) {
            return self
                .lookup_alidns_https_ech(APP_API_PIXIV_NET_ECH_BOOTSTRAP_HOST)
                .await
                .map(Some);
        }

        Ok(None)
    }

    async fn lookup_alidns_https_ech(&self, host: &str) -> Result<Vec<u8>, RhttpError> {
        let response = self
            .client
            .get(self.ech_endpoint.clone())
            .query(&[("name", host), ("type", "HTTPS")])
            .header("accept", "application/json")
            .send()
            .await
            .map_err(|e| {
                RhttpError::RhttpUnknownError(format!("AliDNS ECH request failed: {e}"))
            })?;

        let status = response.status();
        if !status.is_success() {
            return Err(RhttpError::RhttpUnknownError(format!(
                "AliDNS ECH query failed with status {status}"
            )));
        }

        let body = response.bytes().await.map_err(|e| {
            RhttpError::RhttpUnknownError(format!("AliDNS ECH body read failed: {e}"))
        })?;

        parse_alidns_https_ech_response(body.as_ref())
    }
}

fn parse_alidns_https_ech_response(body: &[u8]) -> Result<Vec<u8>, RhttpError> {
    let payload: Value = serde_json::from_slice(body)
        .map_err(|e| RhttpError::RhttpUnknownError(format!("Invalid AliDNS ECH JSON: {e}")))?;

    let status = payload
        .get("Status")
        .and_then(Value::as_u64)
        .ok_or_else(|| {
            RhttpError::RhttpUnknownError("AliDNS ECH response missing Status".to_string())
        })?;
    if status != 0 {
        return Err(RhttpError::RhttpUnknownError(format!(
            "AliDNS ECH response returned status {status}"
        )));
    }

    let answers = payload
        .get("Answer")
        .and_then(Value::as_array)
        .ok_or_else(|| {
            RhttpError::RhttpUnknownError("AliDNS ECH response missing Answer".to_string())
        })?;

    for answer in answers {
        let Some(data) = answer.get("data").and_then(Value::as_str) else {
            continue;
        };
        let Some(encoded_ech) = extract_https_svc_param(data, "ech") else {
            continue;
        };

        let ech = base64::engine::general_purpose::STANDARD
            .decode(encoded_ech)
            .map_err(|e| {
                RhttpError::RhttpUnknownError(format!("Invalid AliDNS ECH base64: {e}"))
            })?;
        return Ok(ech);
    }

    Err(RhttpError::RhttpUnknownError(
        "AliDNS ECH response did not include an ech parameter".to_string(),
    ))
}

fn extract_https_svc_param<'a>(data: &'a str, key: &str) -> Option<&'a str> {
    let prefix = format!("{key}=\"");
    let start = data.find(prefix.as_str())? + prefix.len();
    let tail = &data[start..];
    let end = tail.find('"')?;
    Some(&tail[..end])
}

#[derive(Debug)]
struct NoVerifier;

impl ServerCertVerifier for NoVerifier {
    fn verify_server_cert(
        &self,
        _end_entity: &CertificateDer<'_>,
        _intermediates: &[CertificateDer<'_>],
        _server_name: &ServerName<'_>,
        _ocsp_response: &[u8],
        _now: UnixTime,
    ) -> Result<ServerCertVerified, TlsError> {
        Ok(ServerCertVerified::assertion())
    }

    fn verify_tls12_signature(
        &self,
        _message: &[u8],
        _cert: &CertificateDer<'_>,
        _dss: &DigitallySignedStruct,
    ) -> Result<HandshakeSignatureValid, TlsError> {
        Ok(HandshakeSignatureValid::assertion())
    }

    fn verify_tls13_signature(
        &self,
        _message: &[u8],
        _cert: &CertificateDer<'_>,
        _dss: &DigitallySignedStruct,
    ) -> Result<HandshakeSignatureValid, TlsError> {
        Ok(HandshakeSignatureValid::assertion())
    }

    fn supported_verify_schemes(&self) -> Vec<SignatureScheme> {
        vec![
            SignatureScheme::RSA_PKCS1_SHA1,
            SignatureScheme::ECDSA_SHA1_Legacy,
            SignatureScheme::RSA_PKCS1_SHA256,
            SignatureScheme::ECDSA_NISTP256_SHA256,
            SignatureScheme::RSA_PKCS1_SHA384,
            SignatureScheme::ECDSA_NISTP384_SHA384,
            SignatureScheme::RSA_PKCS1_SHA512,
            SignatureScheme::ECDSA_NISTP521_SHA512,
            SignatureScheme::RSA_PSS_SHA256,
            SignatureScheme::RSA_PSS_SHA384,
            SignatureScheme::RSA_PSS_SHA512,
            SignatureScheme::ED25519,
            SignatureScheme::ED448,
        ]
    }
}

#[frb(sync)]
pub fn create_static_resolver_sync(settings: StaticDnsSettings) -> DnsSettings {
    DnsSettings::StaticDns(settings)
}

#[frb(sync)]
pub fn create_dynamic_resolver_sync(
    resolver: impl Fn(String) -> DartFnFuture<Vec<String>> + 'static + Send + Sync,
) -> DnsSettings {
    DnsSettings::DynamicDns(DynamicDnsSettings {
        resolver: Arc::new(resolver),
    })
}
