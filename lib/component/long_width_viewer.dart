import 'package:flutter/material.dart';

class LongWidgetViewer extends StatefulWidget {
  final String url;
  final int height;

  const LongWidgetViewer({Key? key, required this.url, required this.height})
      : super(key: key);

  @override
  _LongWidgetViewerState createState() => _LongWidgetViewerState();
}

class _LongWidgetViewerState extends State<LongWidgetViewer> {

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
