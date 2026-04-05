import 'dart:typed_data';

extension Uint8ListExt on Uint8List {
  Stream<Uint8List> toStream({required int chunkSize}) async* {
    final byteArray = this;

    int offset = 0;
    while (offset < byteArray.length) {
      int end = offset + chunkSize;
      if (end > byteArray.length) end = byteArray.length;

      // Create a view of the data without copying
      var chunk = Uint8List.sublistView(byteArray, offset, end);
      yield chunk;

      offset = end;
    }
  }
}

extension ByteStreamExt on Stream<List<int>> {
  Future<Uint8List> toUint8List() async {
    // Using BytesBuilder to efficiently concatenate all bytes
    final bytesBuilder = BytesBuilder(copy: false);
    await for (final chunk in this) {
      bytesBuilder.add(chunk);
    }

    return bytesBuilder.takeBytes();
  }
}
