/*
 * Copyright (C) 2020. by perol_notsf, All rights reserved
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program. If not, see <http://www.gnu.org/licenses/>.
 *
 */

import 'package:fluent_ui/fluent_ui.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/models/create_user_response.dart';
import 'package:pixez/network/account_client.dart';
import 'package:url_launcher/url_launcher.dart';

class CreateUserPage extends StatefulWidget {
  @override
  _CreateUserPageState createState() => _CreateUserPageState();
}

class _CreateUserPageState extends State<CreateUserPage> {
  late TextEditingController _userNameController;

  @override
  void initState() {
    _userNameController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _userNameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: PageHeader(
        title: Text(I18n.of(context).input_nickname),
      ),
      content: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Builder(builder: (context) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                InfoLabel(
                  label: '${I18n.of(context).nickname} *',
                  child: TextBox(
                    maxLines: 1,
                    prefix: Icon(FluentIcons.user_event),
                    placeholder: I18n.of(context).nickname,
                    controller: _userNameController,
                  ),
                ),
                FilledButton(
                  onPressed: () async {
                    try {
                      final name = _userNameController.text.trim();
                      if (name.isEmpty) return;
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
                      showSnackbar(context, Snackbar(content: Text("创建次数过多")));
                    }
                  },
                  child: Text("Start"),
                ),
                Center(
                  child: Text(I18n.of(context).nickname_can_be_change_anytime),
                ),
                HyperlinkButton(
                  child: Text(
                    I18n.of(context).terms,
                  ),
                  onPressed: () async {
                    final url = 'https://www.pixiv.net/terms/?page=term';
                    try {
                      await launch(url);
                    } catch (e) {}
                  },
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
