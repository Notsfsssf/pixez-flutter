import 'dart:convert';
import 'dart:typed_data';

import 'package:http_profile/http_profile.dart';
import 'package:rhttp/src/model/request.dart';
import 'package:rhttp/src/model/response.dart';
import 'package:rhttp/src/model/settings.dart';
import 'package:rhttp/src/util/http_header.dart';

HttpClientRequestProfile? createDevToolsProfile({
  required HttpRequest request,
  required String url,
  required HttpHeaders? headers,
}) {
  final profile = HttpClientRequestProfile.profile(
    requestStartTime: DateTime.now(),
    requestMethod: request.method.value,
    requestUri: switch (request.query?.isNotEmpty ?? false) {
      true => Uri.parse(url).replace(queryParameters: request.query).toString(),
      false => url,
    },
  );

  if (profile == null) {
    return null;
  }

  profile.connectionInfo = {'package': 'package:rhttp'};

  profile.requestData
    ..headersListValues = headers?.toMapList()
    ..maxRedirects = switch (request.settings?.redirectSettings) {
      LimitedRedirects limited => limited.maxRedirects,
      NoRedirectSetting _ => 0,
      null => null,
    };

  final Uint8List? body = switch (request.body) {
    HttpBodyText text => utf8.encode(text.text),
    HttpBodyJson json => utf8.encode(jsonEncode(json.json)),
    HttpBodyBytes bytes => bytes.bytes,
    HttpBodyBytesStream _ => utf8.encode('<stream>'),
    HttpBodyForm form => utf8.encode(
      form.form.entries.map((e) => '${e.key}=${e.value}').join('&'),
    ),
    HttpBodyMultipart multipart => utf8.encode(
      multipart.parts.map((e) => '${e.$1}=<...>').join('&'),
    ),
    null => null,
  };

  if (body != null) {
    profile.requestData.bodySink.add(body);
    profile.requestData.bodySink.close();
  }

  return profile;
}

extension HttpClientRequestProfileExt on HttpClientRequestProfile {
  void trackResponse(HttpResponse response) {
    assert(response is! HttpStreamResponse);

    trackCustomResponse(
      statusCode: response.statusCode,
      headers: response.headers,
      body: switch (response) {
        HttpTextResponse() => utf8.encode(response.body),
        HttpBytesResponse() => response.body,
        HttpStreamResponse() => throw 'Should not happen. Report this issue.',
      },
    );
  }

  void trackStreamResponse({
    required HttpStreamResponse response,
    required Uint8List streamBody,
  }) {
    trackCustomResponse(
      statusCode: response.statusCode,
      headers: response.headers,
      body: streamBody,
    );
  }

  void trackCustomResponse({
    required int statusCode,
    required List<(String, String)> headers,
    required Object? body,
  }) {
    final profile = this;

    profile.requestData.close();

    profile.responseData
      ..statusCode = statusCode
      ..headersListValues = headers.asHeaderMapList;

    final bodyBytes = switch (body) {
      String() => utf8.encode(body),
      Uint8List() => body,
      _ => null,
    };

    if (bodyBytes != null) {
      profile.responseData.bodySink.add(bodyBytes);
      profile.responseData.bodySink.close();
    }

    profile.responseData.close();
  }

  void trackError({
    required String error,
  }) {
    final profile = this;

    profile.requestData.closeWithError(error);
    profile.responseData.closeWithError(error);
  }
}
