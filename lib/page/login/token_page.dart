import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/account.dart';
import 'package:pixez/network/oauth_client.dart';
import 'package:pixez/page/hello/android_hello_page.dart';
import 'package:pixez/page/hello/hello_page.dart';

class TokenPage extends StatefulWidget {
  @override
  _TokenPageState createState() => _TokenPageState();
}

class _TokenPageState extends State<TokenPage> {
  String errorMessage = "";
  TextEditingController userNameController = TextEditingController();

  @override
  void dispose() {
    userNameController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            TextFormField(
              maxLines: 1,
              decoration: const InputDecoration(
                icon: Icon(Icons.supervised_user_circle),
                hintText: 'token',
                labelText: 'token',
              ),
              controller: userNameController,
              autofillHints: [AutofillHints.username],
            ),
            RaisedButton(
              onPressed: () async {
                if (userNameController.text.isEmpty) return;
                try {
                  String token = userNameController.text.toString();
                  var response1 = await oAuthClient.postRefreshAuthToken(
                      refreshToken: token);
                  AccountResponse accountResponse =
                      Account.fromJson(response1.data).response;
                  final user = accountResponse.user;
                  AccountProvider accountProvider = new AccountProvider();
                  await accountProvider.open();
                  await accountProvider.insert(AccountPersist()
                    ..passWord = ""
                    ..accessToken = accountResponse.accessToken
                    ..deviceToken = accountResponse.deviceToken ?? ""
                    ..refreshToken = accountResponse.refreshToken
                    ..userImage = user.profileImageUrls.px170x170
                    ..userId = user.id
                    ..name = user.name
                    ..isMailAuthorized = bti(user.isMailAuthorized)
                    ..isPremium = bti(user.isPremium)
                    ..mailAddress = user.mailAddress
                    ..account = user.account
                    ..xRestrict = user.xRestrict);
                  await accountStore.fetch();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (BuildContext context) =>
                            Platform.isIOS ? HelloPage() : AndroidHelloPage()),
                    (route) => route == null,
                  );
                } catch (e) {
                  setState(() {
                    errorMessage = e.toString();
                  });
                }
              },
              child: Text("Next"),
            ),
            Visibility(
              visible: errorMessage != null,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 4.0, horizontal: 0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.all(Radius.circular(4.0)),
                  ),
                  padding: EdgeInsets.all(4.0),
                  child: Text(
                    errorMessage ?? "",
                    textAlign: TextAlign.start,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  int bti(bool bool) {
    if (bool) {
      return 1;
    } else
      return 0;
  }
}
