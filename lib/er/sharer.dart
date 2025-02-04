import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';

class Sharer {
  static Future<void> exportUint8List(
      BuildContext context, Uint8List uint8List, String fileName) async {
    final tempDir = await getTemporaryDirectory();
    final file = File(p.join(tempDir.path, fileName));
    await file.writeAsBytes(uint8List);
    final box = context.findRenderObject() as RenderBox?;
    Rect? rect;
    if (box != null) {
      rect = box.localToGlobal(Offset.zero) & box.size;
    }
    Share.shareXFiles([XFile(file.path)], sharePositionOrigin: rect);
  }
}
