import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class UgoiraWidget extends StatefulWidget {
  final List<FileSystemEntity> drawPools;
  final int delay;
  final double height;
  const UgoiraWidget(
      {Key key,
      @required this.drawPools,
      @required this.delay,
      @required this.height})
      : super(key: key);
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

  Timer _timer;

  initBind() async {
    _timer =
        Timer.periodic(Duration(milliseconds: widget.delay), (timer) async {
      print("task in");
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
            //  size: Size(MediaQuery.of(context).size.width, widget.height),
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
    canvas.drawImage(image, Offset.zero, _paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
