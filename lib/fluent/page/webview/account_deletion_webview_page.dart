import 'package:fluent_ui/fluent_ui.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/utils/webview.dart';

class AccountDeletionPage extends StatefulWidget {
  const AccountDeletionPage({Key? key}) : super(key: key);

  @override
  State<AccountDeletionPage> createState() => _AccountDeletionPageState();
}

class _AccountDeletionPageState extends State<AccountDeletionPage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController();
    initializeWebViewController(
      _controller,
      isActive: () => mounted,
      load: () => _controller.loadRequest(
        Uri.parse('https://www.pixiv.net/leave_pixiv.php'),
      ),
    );
  }

  @override
  void dispose() {
    disposeWebViewController(_controller);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: PageHeader(title: Text(I18n.of(context).account_deletion)),
      content: WebViewWidget(controller: _controller),
    );
  }
}
