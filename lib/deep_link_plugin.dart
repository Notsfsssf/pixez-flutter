import 'dart:async';

import 'package:flutter/services.dart';

class DeepLinkPlugin {
  static const MethodChannel _mChannel = MethodChannel('deep_links/messages');
  static const EventChannel _eChannel = EventChannel('deep_links/events');

  static Future<String?> getInitialLink() =>
      _mChannel.invokeMethod<String?>('getInitialLink');

  static Future<Uri?> getInitialUri() async {
    final link = await getInitialLink();
    if (link == null) return null;
    return Uri.parse(link);
  }

  static Stream<String?> get linkStream => _eChannel
      .receiveBroadcastStream()
      .map<String?>((dynamic link) => link as String?);

  static late final uriLinkStream = linkStream.transform<Uri?>(
    StreamTransformer<String?, Uri?>.fromHandlers(
      handleData: (String? link, EventSink<Uri?> sink) {
        if (link == null) {
          sink.add(null);
        } else {
          sink.add(Uri.parse(link));
        }
      },
    ),
  );

  @Deprecated('Use [linkStream]')
  Stream<String?> getLinksStream() => linkStream;

  @Deprecated('Use [uriLinkStream]')
  Stream<Uri?> getUriLinksStream() => uriLinkStream;
}
