library gifencoder;

import "dart:typed_data";
import "lzw.dart" as lzw;

// Spec: http://www.w3.org/Graphics/GIF/spec-gif89a.txt
// Explanation: http://www.matthewflickinger.com/lab/whatsinagif/bits_and_bytes.asp
// Also see: http://en.wikipedia.org/wiki/File:Quilt_design_as_46x46_uncompressed_GIF.gif

const maxColorBits = 8;
const maxColors = 1 << maxColorBits;

/**
 * Creates a GIF from per-pixel rgba data, ignoring the alpha channel.
 * Returns a list of bytes. Throws an exception if the the image has too
 * many colors.
 *
 * (The input format is the same as the "data" field of the html.ImageData class,
 * which can be created from a canvas element.)
 */
Uint8List makeGif(int width, int height, List<int> rgba) {
  var b = new GifBuffer(width, height);
  b.add(rgba);
  return b.build(1);
}

/**
 * An incomplete GIF, possibly animated.
 */
class GifBuffer {
  final int width;
  final int height;
  final _colors = new _ColorTableBuilder();
  final _frames = new List<Uint8List>();

  /// Creates an incomplete gif of the specified width and height and zero frames.
  GifBuffer(this.width, this.height);

  /**
   * Adds a frame to the animation. The pixels are specified as rgba data but the alpha channel is
   * ignored. Throws an exception if we run out of colors.
   */
  void add(List<int> rgba) {
    _frames.add(_colors.indexImage(width, height, rgba));
  }

  /// Returns the bytes of the GIF. If more than one frame has been added, it will be animated.
  Uint8List build(int framesPerSecond) {
    var colors = _colors.build();
    int delay = 100 ~/ framesPerSecond;
    if (delay < 6) {
      delay =
          6; // http://nullsleep.tumblr.com/post/16524517190/animated-gif-minimum-frame-delay-browser-compatibility
    }

    List<List<int>> bytes = [];
    bytes.add(_header(width, height, colors.bits));
    bytes.add(colors.table);

    if (_frames.length <= 1) {
      // not animated
      if (_frames.length == 1) {
        bytes
          ..add(_startImage(0, 0, width, height))
          ..add(lzw.compress(_frames[0], colors.bits));
      }
    } else {
      bytes.add(_loop(0));

      for (int i = 0; i < _frames.length; i++) {
        var frame = _frames[i];
        bytes
          ..add(_delayNext(delay))
          ..add(_startImage(0, 0, width, height))
          ..add(lzw.compress(frame, colors.bits));
      }
    }
    bytes.add(_trailer());

    int len = 0;
    for (var chunk in bytes) {
      len += chunk.length;
    }

    Uint8List result = new Uint8List(len);
    int offset = 0;
    for (var chunk in bytes) {
      result.setRange(offset, offset + chunk.length, chunk);
      offset += chunk.length;
    }
    assert(offset == len);
    return result;
  }
}

class _ColorTableBuilder {
  final List<int> table = new List<int>();
  final colorToIndex = new Map<int, int>();
  int bits;

  /**
   *  Given rgba data, add each color to the color table.
   *  Returns the same pixels as color indexes.
   *  Throws an exception if we run out of colors.
   */
  Uint8List indexImage(int width, int height, List<int> rgba) {
    var pixels = new Uint8List(width * height);
    assert(pixels.length == rgba.length / 4);
    for (int i = 0; i < rgba.length; i += 4) {
      int color = rgba[i] << 16 | rgba[i + 1] << 8 | rgba[i + 2];
      int index = colorToIndex[color];
      if (index == null) {
        if (colorToIndex.length == maxColors) {
          throw new Exception("image has more than ${maxColors} colors");
        }
        index = table.length ~/ 3;
        colorToIndex[color] = index;
        table..add(rgba[i])..add(rgba[i + 1])..add(rgba[i + 2]);
      }
      pixels[i >> 2] = index;
    }
    return pixels;
  }

  /**
   * Pads the color table with zeros to the next power of 2 and sets bits.
   */
  _ColorTable build() {
    for (int bits = 1; bits <= 8; bits++) {
      int colors = 1 << bits;
      if (colors * 3 >= table.length) {
        var copy = new Uint8List(colors * 3);
        copy.setRange(0, table.length, table);
        return new _ColorTable(bits, copy);
      }
    }
    throw new Exception("internal error; too many colors");
  }
}

class _ColorTable {
  final int bits;
  final Uint8List table;

  _ColorTable(this.bits, this.table);

  int get numColors {
    return table.length ~/ 3;
  }
}

List<int> _header(int width, int height, int colorBits) {
  const _headerBlock = const [0x47, 0x49, 0x46, 0x38, 0x39, 0x61]; // GIF 89a

  List<int> bytes = [];
  bytes.addAll(_headerBlock);
  _addShort(bytes, width);
  _addShort(bytes, height);
  bytes..add(0xF0 | colorBits - 1)..add(0)..add(0);
  return bytes;
}

// See: http://odur.let.rug.nl/~kleiweg/gif/netscape.html
List<int> _loop(int reps) {
  List<int> bytes = [0x21, 0xff, 0x0B];
  bytes.addAll("NETSCAPE2.0".codeUnits);
  bytes.addAll([3, 1]);
  _addShort(bytes, reps);
  bytes.add(0);
  return bytes;
}

List<int> _delayNext(int centiseconds) {
  var bytes = [0x21, 0xF9, 4, 0];
  _addShort(bytes, centiseconds);
  bytes..add(0)..add(0);
  return bytes;
}

List<int> _startImage(int left, int top, int width, int height) {
  List<int> bytes = [0x2C];
  _addShort(bytes, left);
  _addShort(bytes, top);
  _addShort(bytes, width);
  _addShort(bytes, height);
  bytes.add(0);
  return bytes;
}

List<int> _trailer() {
  return [0x3b];
}

void _addShort(List<int> dest, int n) {
  if (n < 0 || n > 0xFFFF) {
    throw new Exception("out of range for short: ${n}");
  }
  dest..add(n & 0xff)..add(n >> 8);
}
