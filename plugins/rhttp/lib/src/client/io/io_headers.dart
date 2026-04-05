import 'dart:io';

import 'package:meta/meta.dart';

@internal
class RhttpIoHeaders implements HttpHeaders {
  final Map<String, List<String>> headers = {};

  @override
  bool chunkedTransferEncoding = false;

  @override
  int contentLength = -1;

  @override
  ContentType? contentType;

  @override
  DateTime? date;

  @override
  DateTime? expires;

  @override
  String? host;

  @override
  DateTime? ifModifiedSince;

  @override
  bool persistentConnection = true;

  @override
  int? port;

  @override
  List<String>? operator [](String name) => headers[name];

  @override
  void add(String name, Object value, {bool preserveHeaderCase = false}) {
    if (preserveHeaderCase) {
      headers.putIfAbsent(name.toLowerCase(), () => []).add(value.toString());
    } else {
      headers.putIfAbsent(name, () => []).add(value.toString());
    }
  }

  @override
  void clear() {
    headers.clear();
  }

  @override
  void forEach(void Function(String name, List<String> values) action) {
    headers.forEach(action);
  }

  @override
  void noFolding(String name) =>
      throw UnimplementedError("noFolding is not supported");

  @override
  void remove(String name, Object value) {
    headers[name]?.remove(value.toString());
    if (headers[name]?.isEmpty ?? false) {
      headers.remove(name);
    }
  }

  @override
  void removeAll(String name) {
    headers.remove(name);
  }

  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {
    if (preserveHeaderCase) {
      headers[name.toLowerCase()] = [value.toString()];
    } else {
      headers[name] = [value.toString()];
    }
  }

  @override
  String? value(String name) {
    return headers[name]?.firstOrNull;
  }
}
