import 'dart:async';
import 'dart:typed_data';

class ByteStreamSubscription {
  final _bytesBuilder = BytesBuilder(copy: false);
  final _completer = Completer<void>();

  void addBytes(Uint8List bytes) {
    _bytesBuilder.add(bytes);
  }

  void close() {
    _completer.complete();
  }

  /// Returns a future that completes
  /// when all bytes have been added to the stream.
  Future<Uint8List> waitForBytes() async {
    await _completer.future;
    return _bytesBuilder.takeBytes();
  }
}
