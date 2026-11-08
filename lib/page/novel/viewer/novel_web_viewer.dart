import 'package:dio/dio.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pixez/utils/webview.dart';
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
          final controller = WebViewController();
          _controller = controller;
          initializeWebViewController(
            controller,
            isActive: () => mounted,
            load: () => controller.loadHtmlString(initNovelHtml ?? ""),
          );
        });
      }
    } catch (e) {}
  }

  @override
  void dispose() {
    disposeWebViewController(_controller);
    super.dispose();
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
