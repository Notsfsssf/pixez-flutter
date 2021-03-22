// import 'package:flutter/material.dart';
// import 'package:pixez/er/leader.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:webview_flutter/webview_flutter.dart';

// class SimpleWebviewPage extends StatefulWidget {
//   final String url;

//   const SimpleWebviewPage({Key? key, required this.url}) : super(key: key);
//   @override
//   _SimpleWebviewPageState createState() => _SimpleWebviewPageState();
// }

// class _SimpleWebviewPageState extends State<SimpleWebviewPage> {
//   WebViewController? _webViewController;
//   int progressValue = 0;
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(""),
//         actions: <Widget>[
//           IconButton(
//               icon: Icon(Icons.open_in_browser),
//               onPressed: () => launch(widget.url)),
//           IconButton(
//               icon: Icon(Icons.refresh),
//               onPressed: () => _webViewController?.reload())
//         ],
//       ),
//       body: Builder(builder: (BuildContext context) {
//         return Column(
//           children: [
//             Visibility(
//               visible: progressValue < 100,
//               child: LinearProgressIndicator(
//                 value: progressValue / 100,
//               ),
//             ),
//             Expanded(
//               child: WebView(
//                 initialUrl: widget.url,
//                 javascriptMode: JavascriptMode.unrestricted,
//                 onWebViewCreated: (WebViewController webViewController) {},
//                 onProgress: (int progress) {
//                   print("WebView is loading (progress : $progress%)");
//                   setState(() {
//                     progressValue = progress;
//                   });
//                 },
//                 navigationDelegate: (NavigationRequest request) {
//                   var uri = Uri.parse(request.url);
//                   if (uri.scheme == "pixiv") {
//                     Leader.pushWithUri(context, uri);
//                     Navigator.of(context).pop();
//                     return NavigationDecision.prevent;
//                   }
//                   return NavigationDecision.navigate;
//                 },
//                 onPageStarted: (String url) {
//                   print('Page started loading: $url');
//                 },
//                 onPageFinished: (String url) {
//                   print('Page finished loading: $url');
//                 },
//                 gestureNavigationEnabled: true,
//               ),
//             ),
//           ],
//         );
//       }),
//     );
//   }
// }
