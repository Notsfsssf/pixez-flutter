/*
 * Copyright (C) 2020. by perol_notsf, All rights reserved
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program. If not, see <http://www.gnu.org/licenses/>.
 *
 */

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
    Key? key,
    required this.drawPools,
    required this.delay,
    required this.size,
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
  ui.Image? image;

  @override
  void initState() {
    super.initState();
    initBind();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  late Timer _timer;

  initBind() async {
    _timer =
        Timer.periodic(Duration(milliseconds: widget.delay), (timer) async {
      File file = widget.drawPools[point] as File;
      point++;
      if (point >= widget.drawPools.length) point = 0;
      final data = await _loadImage(file);
      if (mounted) {
        setState(() {
          image = data;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return image != null
        ? CustomPaint(
            painter: UgoiraPainter(image!),
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
    Rect dstRect =
        Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());
    canvas.drawImageRect(
        image,
        dstRect,
        Rect.fromLTWH(0, 0, size.width.toDouble(), size.height.toDouble()),
        _paint);
  }

  @override
  bool shouldRepaint(UgoiraPainter oldDelegate) {
    return oldDelegate.image != image;
  }
}
