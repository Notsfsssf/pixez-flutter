import 'package:material_ui/material_ui.dart';
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

  Future<void> _submit() async {
    if (userNameController.text.isEmpty) return;
    try {
      String token = userNameController.text.toString();
      var response1 = await oAuthClient.postRefreshAuthToken(
        refreshToken: token,
      );
      AccountResponse accountResponse = Account.fromJson(
        response1.data,
      ).response;
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
        isMailAuthorized: user.isMailAuthorized ? 1 : 0,
      );
      await accountProvider.insert(accountPersist);
      await accountStore.fetch();
      Leader.pushUntilHome(context);
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Token'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            maxLines: 1,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Pixiv token'),
            controller: userNameController,
            autofillHints: [AutofillHints.username],
            onFieldSubmitted: (_) => _submit(),
          ),
          Visibility(
            visible: errorMessage.isNotEmpty,
            child: _buildErrorMessage(context),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(I18n.of(context).cancel),
        ),
        FilledButton(onPressed: _submit, child: Text(I18n.of(context).submit)),
      ],
    );
  }

  Widget _buildErrorMessage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 0),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.2,
        ),
        child: SingleChildScrollView(
          child: Text(
            errorMessage,
            textAlign: TextAlign.start,
            style: TextStyle(color: Colors.redAccent),
          ),
        ),
      ),
    );
  }
}
