## 0.16.0

- deps: bump `flutter_rust_bridge` to `2.12.0`
- deps: bump Rust dependencies to latest versions

## 0.15.1

- chore: migrate from GitHub to Codeberg: https://codeberg.org/Tienisto/rhttp

## 0.15.0

- fix: `RhttpCompatibleClient` should combine header values with the same key using comma as per `http` spec (#95)
- fix: crash on non-UTF8 headers (#92)
- deps: bump `freezed` to `^3.0.0`
- deps: bump Rust dependencies to latest versions

## 0.14.0

- feat: `RhttpCompatibleClient` supports `Abortable` added in `http` v1.5.0
- feat: support Android 16 KB memory page alignment requirement @sabin26 (#89)
- feat: add `queryRaw` parameter @nrbnlulu (#86)
- deps: bump Rust dependencies to latest versions

## 0.13.0

- feat: add `HttpResponse.remoteIp` to get the remote IP address of the server
- feat: set `forceSameCodegenVersion: false` to disable check by `flutter_rust_bridge`
- deps: bump `flutter_rust_bridge` to `2.11.1`
- deps: bump Rust dependencies to latest versions
- docs: update Android example @FrankenApps (#78)

## 0.12.0

- fix: Flutter 3.32 compatibility @MSOB7YY (#74)
- deps: bump `flutter_rust_bridge` to `2.10.0`

## 0.11.1

- feat: add basic Cookie handling @FrankenApps (#67)
- feat: automatically install the pinned Rust version @linsui (#68)
- deps: loosen `freezed_annotation` constraint to `>=2.4.4 <4.0.0`

## 0.11.0

- feat: `HttpMethod` accepts any string as method name @wgh136 (#57)
- feat: add `ClientSettings.userAgent` @FrankenApps (#63)
- fix: race condition leading to `ConcurrentModificationError` when using the same `CancelToken` for multiple requests
- docs: add internet permission to example app
- deps: bump `flutter_rust_bridge` to `2.9.0`

## 0.10.0

- feat: use `rustls-tls-webpki-roots` to avoid errors with corrupted system setting
- feat: simplify `BaseHttpRequest` and `HttpRequest` constructor @FrankenApps (#52)
- fix: `requestStream` never return if cancelled immediately using `CancelToken` @xalanq (#54)
- deps: bump `flutter_rust_bridge` to `2.7.1`

## 0.9.8

- deps: bump `freezed_annotation` constraint to `^2.4.4`

## 0.9.7

- feat: add `TlsSettings.sni` to configure Server Name Indication for TLS (default: `true`) (#43)
- deps: bump `flutter_rust_bridge` to `2.7.0`

## 0.9.6

- fix: missing response body in DevTools when using Stream response
- fix: Stream not finishing when using `onReceiveProgress`

## 0.9.5

- feat: DevTools integration (Network Tab)
- feat: `HttpBody.json` now accepts `Object?` instead of `Map<String, dynamic>` to align with JSON spec

## 0.9.4

- feat: allow specifying ports in `DnsSettings`
- fix: timeout exception when using `DnsSettings` (#39)
- fix: do not emit final `(-1, -1)` progress event when content length is unknown

## 0.9.3

- feat: `onSendProgress` should infer `total` also from `Content-Length` header
- feat: optimize compiled binary size @xalanq #40
- fix: `Unhandled Exception` when `HttpBody.stream` or `HttpBody.bytes` with `onSendProgress` is canceled

## 0.9.2

- feat: add `--remap-path-prefix=$HOME/.cargo/=/.cargo/` to `RUSTFLAGS` to be more reproducible
- feat: respect channel in `rust-toolchain.toml`
- fix: support text body compressed in `gzip` and `brotli`
- fix: `requestStream` should throw `RhttpCancelException` instead of emitting an `Unhandled Exception` when request is canceled
- deps: bump `flutter_rust_bridge` to `2.6.0`

## 0.9.1

- feat: allow reuse of same `CancelToken` for multiple requests, all requests are canceled when token is canceled

## 0.9.0

- feat: add `ProxySettings.proxy('http://localhost:8080')` and other proxy settings
- feat: improve performance when uploading a byte stream
- feat: improve performance when tracking progress during download of a large binary file
- feat: `onSendProgress` and `onReceiveProgress` now always emit the final progress event (100%)
- fix: set `idleTimeout` in `IoCompatibleClient` no longer throws an exception

## 0.8.2

- fix: possible `CloseStreamException` when using `IoCompatibleClient`
- deps: bump `flutter_rust_bridge` to `2.5.1`

## 0.8.1

- deps: bump `flutter_rust_bridge` to `2.5.0`

## 0.8.0

- feat: add `IoCompatibleClient`, a compatibility layer for dart:io's `HttpClient`
- feat: add `dnsSettings` to `ClientSettings` to provide custom DNS resolution
- **BREAKING**: `timeout` and `connectTimeout` moved to `TimeoutSettings` (deprecated in 0.7.2)

## 0.7.2

- feat: add `keepAliveTimeout`, `keepAlivePing` to new `TimeoutSettings` (@nicobritos)
- **DEPRECATED**: `timeout` and `connectTimeout` moved to `TimeoutSettings`

## 0.7.1

- fix: export `RhttpInvalidCertificateException`, `RhttpConnectionException`
- deps: remove `plugin_platform_interface` dependency
- deps: bump `flutter_rust_bridge` to `2.4.0`

## 0.7.0

- fix: creating a second client might overwrite the first client due to memory address conflict
- **BREAKING**: change `RhttpInvalidClientException` to `RhttpClientDisposedException`

## 0.6.2

- feat: add `baseUrl` setting to `ClientSettings`
- feat: add `redirectSettings` to `ClientSettings`
- feat: add `RhttpRedirectException`
- feat: `RhttpCompatibleClient.close` cancels all running requests similar to `IOClient` of `http` package

## 0.6.1

- feat: add `onSendProgress` and `onReceiveProgress`
- feat: increase performance of `HttpBody.stream`
- feat: always compile Rust in release mode

## 0.6.0

- feat: add `HttpBody.stream` to send a stream as request body
- feat: `RhttpCompatibleClient` sets `throwOnStatusCode` to `false` to conform with `http` package

## 0.5.4

- feat: wrap any exception in `RhttpCompatibleClient` into `RhttpWrappedClientException`

## 0.5.3

- feat: add `RhttpConnectionException` to catch connection errors like no internet, server not reachable, etc.
- feat: add `RhttpCompatibleClient.createSync`
- feat: add `cancelRunningRequests` parameter to `RhttpClient.dispose`
- fix: creating a client with HTTP/3 fails with `no async runtime found`

## 0.5.2

- fix: `RetryInterceptor` should throw `RhttpCancelException` if request is canceled during retry

## 0.5.1

- feat: add `RhttpClient.createSync`
- feat: add `HttpHeaders.copyWith`, `HttpHeaders.copyWithout`
- feat: add convenience method: `HttpTextResponse.bodyToJson`
- fix: reset parameters in `RetryInterceptor.shouldRetry` before retrying

## 0.5.0

- feat: interceptors (e.g. `RetryInterceptor`)
- feat: certificate pinning
- feat: client certificate / mutual TLS
- feat: add `ProxySettings`
- **BREAKING**: `requestGeneric` renamed to `request`, `request` removed

## 0.4.0

- feat: add `RhttpCompatibleClient` that is compatible with the [http](https://pub.dev/packages/http) package

## 0.3.2

- docs: update README

## 0.3.1

- docs: add benchmark

## 0.3.0

- feat: add `HttpBody.multipart`
- feat: change `TlsSettings.verifyCerts` to `TlsSettings.verifyCertificates`

## 0.2.0

- feat: add `RhttpStatusCodeException`, `RhttpInvalidCertificateException`
- feat: add `TlsSettings`

## 0.1.0

- feat: request body types
- feat: client for connection pooling / reuse
- feat: cancel requests
- feat: improve error handling with `RhttpException`

## 0.0.2

- feat: query, headers, body

## 0.0.1

- initial release
