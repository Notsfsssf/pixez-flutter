import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:pixez/network/api_client.dart';

class NovelWebViewer extends StatefulWidget {
  final int novelId;
  const NovelWebViewer({super.key, required this.novelId});

  @override
  State<NovelWebViewer> createState() => _NovelWebViewerState();
}

class _NovelWebViewerState extends State<NovelWebViewer> {
  String? initNovelHtml;
  WebViewController? _controller;

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
          _controller = WebViewController()
            ..setJavaScriptMode(JavaScriptMode.unrestricted)
            ..loadHtmlString(initNovelHtml ?? "");
        });
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: initNovelHtml != null && _controller != null
          ? WebViewWidget(controller: _controller!)
          : Container(),
    );
  }
}
