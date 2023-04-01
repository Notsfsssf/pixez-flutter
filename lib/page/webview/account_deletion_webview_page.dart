import 'package:flutter/material.dart';
import 'package:flutter_inappwebview_quill/flutter_inappwebview_quill.dart';
import 'package:pixez/i18n.dart';

class AccountDeletionPage extends StatefulWidget {
  const AccountDeletionPage({Key? key}) : super(key: key);

  @override
  State<AccountDeletionPage> createState() => _AccountDeletionPageState();
}

class _AccountDeletionPageState extends State<AccountDeletionPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(I18n.of(context).account_deletion),
      ),
      body: InAppWebView(
        initialUrlRequest:
            URLRequest(url: Uri.parse("https://www.pixiv.net/leave_pixiv.php")),
        initialOptions: InAppWebViewGroupOptions(
            crossPlatform: InAppWebViewOptions(
              useShouldOverrideUrlLoading: true,
            ),
            android: AndroidInAppWebViewOptions(
              useHybridComposition: true,
            )),
      ),
    );
  }
}
