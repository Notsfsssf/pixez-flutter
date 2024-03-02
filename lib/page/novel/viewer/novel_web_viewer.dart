import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:pixez/network/api_client.dart';

class NovelWebViewer extends StatefulWidget {
  final int novelId;
  const NovelWebViewer({super.key, required this.novelId});

  @override
  State<NovelWebViewer> createState() => _NovelWebViewerState();
}

class _NovelWebViewerState extends State<NovelWebViewer> {
  String? initNovelHtml;
  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  _fetchData() async {
    try {
      Response response = await apiClient.webviewNovel(widget.novelId);
      if (mounted) {
        setState(() {
          initNovelHtml = response.data;
        });
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: initNovelHtml != null ? _buildWebView(context) : Container());
  }

  Widget _buildWebView(BuildContext context) {
    return InAppWebView(
      initialData: InAppWebViewInitialData(data: initNovelHtml ?? ""),
    );
  }
}
