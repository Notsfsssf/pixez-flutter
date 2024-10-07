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
import 'package:pixez/main.dart';
import 'package:pixez/models/ugoira_metadata_response.dart';

class UgoiraWidget extends StatefulWidget {
  final List<FileSystemEntity> drawPools;
  final int delay;
  final Size size;
  final UgoiraMetadataResponse ugoiraMetadataResponse;

  const UgoiraWidget(
      {Key? key,
      required this.drawPools,
      required this.delay,
      required this.size,
      required this.ugoiraMetadataResponse})
      : super(key: key);

  @override
  _UgoiraMaterialState createState() => _UgoiraMaterialState();
}

class _UgoiraMaterialState extends State<UgoiraWidget> with RouteAware {
  Map<File, ui.Image> _map = Map();

  Future<ui.Image> _loadImage(File file) async {
    if (_map.containsKey(file) && _map[file] != null) return _map[file]!;
    final data = await file.readAsBytes();
    var image = await decodeImageFromList(data.buffer.asUint8List());
    _map[file] = image;
    if (_map.length > 10) _map.removeWhere((key, value) => key != file);
    return image;
  }

  int point = 0;
  ui.Image? image;

  @override
  void initState() {
    super.initState();
    initBind();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    super.didPopNext();
    stopPainting = false;
    initBind();
  }

  @override
  void didPushNext() {
    super.didPushNext();
    stopPainting = true;
  }

  bool stopPainting = false;

  initBind() async {
    Future(() => {start()});
  }

  start() async {
    if (stopPainting) return;
    File file = widget.drawPools[point] as File;
    int duration =
        widget.ugoiraMetadataResponse.ugoiraMetadata.frames[point].delay;
    point++;
    if (point >= widget.drawPools.length) point = 0;
    final data = await _loadImage(file);
    if (mounted && !stopPainting) {
      setState(() {
        image = data;
      });
    } else
      return;
    Future.delayed(Duration(milliseconds: duration), () {
      if (mounted && !stopPainting) start();
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
