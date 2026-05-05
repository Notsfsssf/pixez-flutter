import 'package:dio/dio.dart';

class PixivImageSource {
  static const String imageHost = 'i.pximg.net';
  static const String imageSHost = 's.pximg.net';

  static String resolve(
    String url, {
    required bool disableBypassSni,
    required String? pictureSource,
  }) {
    try {
      return resolveUri(
        Uri.parse(url),
        disableBypassSni: disableBypassSni,
        pictureSource: pictureSource,
      ).toString();
    } catch (e) {
      return url;
    }
  }

  static Uri resolveUri(
    Uri uri, {
    required bool disableBypassSni,
    required String? pictureSource,
  }) {
    if (disableBypassSni) return uri;
    if (uri.host != imageHost && uri.host != imageSHost) return uri;

    final source = pictureSource?.trim();
    if (source == null || source.isEmpty) return uri;
    if (source == imageHost) return uri;

    return _withSource(uri, source);
  }

  static Uri _withSource(Uri uri, String source) {
    final normalizedSource = source.startsWith('//')
        ? 'https:$source'
        : source.contains('://')
        ? source
        : 'https://$source';
    final sourceUri = Uri.parse(normalizedSource);
    if (sourceUri.host.isEmpty) return uri;

    return uri.replace(
      scheme: sourceUri.scheme.isEmpty ? uri.scheme : sourceUri.scheme,
      userInfo: sourceUri.userInfo,
      host: sourceUri.host,
      port: sourceUri.hasPort ? sourceUri.port : null,
      path: _joinPaths(sourceUri.path, uri.path),
    );
  }

  static String _joinPaths(String prefix, String suffix) {
    if (prefix.isEmpty || prefix == '/') return suffix;
    if (suffix.isEmpty || suffix == '/') return prefix;
    if (prefix.endsWith('/') && suffix.startsWith('/')) {
      return prefix + suffix.substring(1);
    }
    if (!prefix.endsWith('/') && !suffix.startsWith('/')) {
      return '$prefix/$suffix';
    }
    return '$prefix$suffix';
  }
}

class PixivImageSourceInterceptor extends Interceptor {
  final bool Function() disableBypassSni;
  final String? Function() pictureSource;

  PixivImageSourceInterceptor({
    required this.disableBypassSni,
    required this.pictureSource,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.path = PixivImageSource.resolveUri(
      options.uri,
      disableBypassSni: disableBypassSni(),
      pictureSource: pictureSource(),
    ).toString();
    options.baseUrl = '';
    options.queryParameters.clear();
    handler.next(options);
  }
}
