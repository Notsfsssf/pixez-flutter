import 'package:fluent_ui/fluent_ui.dart';
import 'package:pixez/i18n.dart';

class AccountDeletionPage extends StatefulWidget {
  const AccountDeletionPage({Key? key}) : super(key: key);

  @override
  State<AccountDeletionPage> createState() => _AccountDeletionPageState();
}

class _AccountDeletionPageState extends State<AccountDeletionPage> {
  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
        header: PageHeader(title: Text(I18n.of(context).account_deletion)),
        content: Text('Not Support')
        //  InAppWebView(
        //   initialUrlRequest:
        //       URLRequest(url: Uri.parse("https://www.pixiv.net/leave_pixiv.php")),
        //   initialOptions: InAppWebViewGroupOptions(
        //       crossPlatform: InAppWebViewOptions(
        //         useShouldOverrideUrlLoading: true,
        //       ),
        //       android: AndroidInAppWebViewOptions(
        //         useHybridComposition: true,
        //       )),
        // ),
        );
  }
}
