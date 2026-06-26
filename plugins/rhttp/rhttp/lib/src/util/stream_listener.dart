import 'dart:typed_data';

const _bufferSize = 1024 * 1024; // 1 MB

/// Listens to a stream while handling backpressure.
/// It should not read the stream faster than it can process the data.
Future<void> listenToStreamWithBackpressure({
  required Stream<List<int>> stream,
  required Future<void> Function(Uint8List) onData,
  required Future<void> Function() onDone,
}) async {
  final bytesBuilder = BytesBuilder(copy: false);
  await for (final chunk in stream) {
    bytesBuilder.add(chunk);

    if (bytesBuilder.length > _bufferSize) {
      await onData(bytesBuilder.takeBytes());
    }
  }

  if (bytesBuilder.isNotEmpty) {
    await onData(bytesBuilder.takeBytes());
  }

  await onDone();
}
