import 'package:fluent_ui/fluent_ui.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/account.dart';
import 'package:pixez/network/oauth_client.dart';

class TokenPage extends StatefulWidget {
  @override
  _TokenPageState createState() => _TokenPageState();
}

class _TokenPageState extends State<TokenPage> {
  String errorMessage = "";
  TextEditingController userNameController = TextEditingController();

  @override
  void dispose() {
    userNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      constraints: const BoxConstraints(
        maxWidth: 368.0,
        maxHeight: 300.0,
      ),
      title: const Text('Token'),
      content: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            InfoLabel(
              label: 'Token',
              child: TextFormBox(
                maxLines: 1,
                prefix: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: const Icon(FluentIcons.password_field),
                ),
                placeholder: 'token',
                controller: userNameController,
                autofillHints: [AutofillHints.username],
              ),
            ),
            Visibility(
              visible: errorMessage.isNotEmpty,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 4.0, horizontal: 0),
                child: Container(
                  decoration: BoxDecoration(
                    color: FluentTheme.of(context).accentColor,
                    borderRadius: BorderRadius.all(Radius.circular(4.0)),
                  ),
                  padding: EdgeInsets.all(4.0),
                  child: Text(
                    errorMessage,
                    textAlign: TextAlign.start,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
      actions: [
        Button(
          child: Text(I18n.of(context).cancel),
          onPressed: Navigator.of(context).pop,
        ),
        FilledButton(
          onPressed: () async {
            if (userNameController.text.isEmpty) return;
            try {
              String token = userNameController.text.toString();
              var response1 =
                  await oAuthClient.postRefreshAuthToken(refreshToken: token);
              AccountResponse accountResponse =
                  Account.fromJson(response1.data).response;
              final user = accountResponse.user;
              AccountProvider accountProvider = new AccountProvider();
              await accountProvider.open();
              await accountProvider.deleteByUserId(user.id);
              var accountPersist = AccountPersist(
                  userId: user.id,
                  userImage: user.profileImageUrls.px170x170,
                  accessToken: accountResponse.accessToken,
                  refreshToken: accountResponse.refreshToken,
                  deviceToken: "",
                  passWord: "no more",
                  name: user.name,
                  account: user.account,
                  mailAddress: user.mailAddress,
                  isPremium: user.isPremium ? 1 : 0,
                  xRestrict: user.xRestrict,
                  isMailAuthorized: user.isMailAuthorized ? 1 : 0);
              await accountProvider.insert(accountPersist);
              await accountStore.fetch();
              Leader.pushUntilHome(context);
            } catch (e) {
              setState(() {
                errorMessage = e.toString();
              });
            }
          },
          child: Text("Next"),
        ),
      ],
    );
  }

  int bti(bool bool) {
    if (bool) {
      return 1;
    } else
      return 0;
  }
}
