import 'dart:typed_data';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class LongWidgetViewer extends StatefulWidget {
  final String url;
  final int height;

  const LongWidgetViewer({Key? key, required this.url, required this.height})
      : super(key: key);

  @override
  _LongWidgetViewerState createState() => _LongWidgetViewerState();
}

class _LongWidgetViewerState extends State<LongWidgetViewer> {
  ui.Image? _image;

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
