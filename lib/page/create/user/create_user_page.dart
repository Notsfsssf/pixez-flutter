import 'package:flutter/material.dart';
import 'package:pixez/models/create_user_response.dart';
import 'package:pixez/network/account_client.dart';

class CreateUserPage extends StatefulWidget {
  @override
  _CreateUserPageState createState() => _CreateUserPageState();
}

class _CreateUserPageState extends State<CreateUserPage> {
  TextEditingController _userNameController;

  @override
  void initState() {
    _userNameController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _userNameController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("New User"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                maxLines: 1,
                decoration: const InputDecoration(
                  icon: Icon(Icons.supervised_user_circle),
                  hintText: 'New UserName',
                  labelText: 'New UserName *',
                ),
                controller: _userNameController,
              ),
              RaisedButton(
                onPressed: () async {
                  try {
                    final name = _userNameController.text.trim();
                    if (name == null || name.isEmpty) return;
                    final response =
                        await AccountClient().createProvisionalAccount(name);
                    print(response.data);
                    var createUserResponseFromJson2 =
                        CreateUserResponse.fromJson(response.data);
                    Navigator.of(context).pop(createUserResponseFromJson2);
/*                AccountProvider accountProvider = new AccountProvider();
                    await accountProvider.open();
                    var accountResponse = createUserResponseFromJson2.body;

                  var a=  "Bearer l-f9qZ0ZyqSwRyZs8-MymbtWBbSxmCu1pmbOlyisou8";
                    accountProvider.insert(AccountPersist()
                      ..accessToken = a
                      ..deviceToken = accountResponse.deviceToken
                      ..refreshToken = a
                      ..userImage = ""
                      ..userId = accountResponse.userAccount
                      ..name = user.name
                      ..isMailAuthorized = bti(user.isMailAuthorized)
                      ..isPremium = bti(user.isPremium)
                      ..mailAddress = user.mailAddress
                      ..account = user.account
                      ..xRestrict = user.xRestrict);*/
                  } catch (e) {
                    Scaffold.of(context)
                        .showSnackBar(SnackBar(content: Text("创建次数过多")));
                  }
                },
                child: Text("create"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
