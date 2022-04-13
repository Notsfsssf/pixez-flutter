import 'package:bot_toast/bot_toast.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/network/oauth_client.dart';
import 'package:pixez/page/about/about_page.dart';
import 'package:pixez/page/hello/setting/setting_quality_page.dart';
import 'package:pixez/page/login/login_page.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

class FluentLoginPageState extends LoginPageStateBase {
  @override
  Widget build(BuildContext context) {
    return _buildBody(context);
  }

  Widget _buildBody(BuildContext context) {
    return ContentDialog(
      title: Text("Login"),
      actions: [
        Button(
          onPressed: () async {
            try {
              String url = await OAuthClient.generateWebviewUrl(create: true);
              launch(url);
            } catch (e) {}
          },
          child: Text(I18n.of(context).dont_have_account),
        ),
        FilledButton(
            child: Text(
              I18n.of(context).login,
            ),
            onPressed: () async {
              try {
                String url = await OAuthClient.generateWebviewUrl();
                launch(url);
              } catch (e) {}
            }),
      ],
      content: SingleChildScrollView(
        padding: EdgeInsets.all(0),
        child: Column(
          children: <Widget>[
            Container(
              height: 20,
            ),
            Image.asset(
              'assets/images/icon.png',
              height: 80,
              width: 80,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(10),
                  ),
                  TextButton(
                    child: Text(I18n.of(context).terms),
                    onPressed: () async {
                      final url = 'https://www.pixiv.net/terms/?page=term';
                      try {
                        await launch(url);
                      } catch (e) {}
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(FluentIcons.settings),
                        onPressed: () {
                          Navigator.of(context).push(
                            FluentPageRoute(
                              builder: (context) => ContentDialog(
                                content: SettingQualityPage(),
                              ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(FluentIcons.message),
                        onPressed: () {
                          Navigator.of(context).push(
                            FluentPageRoute(
                              builder: (context) => ContentDialog(
                                content: AboutPage(),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  launch(url) async {
    try {
      await url_launcher.launch(url);
    } catch (e) {
      BotToast.showText(text: e.toString());
      super.launch(url);
    }
  }
}
