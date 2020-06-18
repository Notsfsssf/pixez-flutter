import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class UgoiraWidget extends StatefulWidget {
  final List<FileSystemEntity> drawPools;
  final int delay;
  final Size size;

  const UgoiraWidget({
    Key key,
    @required this.drawPools,
    @required this.delay,
    @required this.size,
  }) : super(key: key);

  @override
  _UgoiraWidgetState createState() => _UgoiraWidgetState();
}

class _UgoiraWidgetState extends State<UgoiraWidget> {
  Future<ui.Image> _loadImage(File file) async {
    final data = await file.readAsBytes();
    return await decodeImageFromList(data.buffer.asUint8List());
  }

  int point = 0;
  ui.Image image;

  @override
  void initState() {
    super.initState();
    initBind();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Timer _timer;

  initBind() async {
    _timer =
        Timer.periodic(Duration(milliseconds: widget.delay), (timer) async {
      File file = widget.drawPools[point];
      point++;
      if (point >= widget.drawPools.length) point = 0;
      final data = await _loadImage(file);
      setState(() {
        image = data;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return image != null
        ? CustomPaint(
            painter: UgoiraPainter(image),
            size: widget.size,
          )
        : Container();
  }
}

class UgoiraPainter extends CustomPainter {
  final ui.Image image;

  Paint _paint = Paint();

  UgoiraPainter(this.image);

  @override
  Future<void> paint(Canvas canvas, Size size) async {
   Rect dstRect = Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());
   canvas.drawImageRect(
       image, dstRect,Rect.fromLTWH(0, 0,size.width.toDouble(), size.height.toDouble()), _paint);
    // canvas.drawImage(image, Offset.zero, _paint);
  }

  @override
  bool shouldRepaint(UgoiraPainter oldDelegate) {
    return oldDelegate.image != image;
  }
}
