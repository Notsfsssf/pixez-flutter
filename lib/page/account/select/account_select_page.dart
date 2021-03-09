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

import 'package:flutter/material.dart';
import 'package:pixez/component/painter_avatar.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/account.dart';
import 'package:pixez/page/login/login_page.dart';

class AccountSelectPage extends StatefulWidget {
  @override
  _AccountSelectPageState createState() => _AccountSelectPageState();
}

class _AccountSelectPageState extends State<AccountSelectPage> {
  @override
  void initState() {
    accountStore.fetch();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: ListView.builder(
          itemBuilder: (context, index) {
            AccountPersist accountPersist = accountStore.accounts[index];
            return ListTile(
              leading: PainterAvatar(
                url: accountStore.accounts[index].userImage,
                id: int.parse(accountStore.accounts[index].userId),
              ),
              title: Text(accountPersist.name),
              subtitle: Text(accountPersist.mailAddress),
              trailing: accountStore.accounts.indexOf(accountStore.now) == index
                  ? Icon(Icons.check)
                  : IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        accountStore.deleteSingle(accountPersist.id!);
                      },
                    ),
              onTap: () {
                if (accountStore.accounts.indexOf(accountStore.now) != index) {
                  accountStore.select(index);
                }
              },
            );
          },
          itemCount: accountStore.accounts.length,
        ),
      ),
      appBar: AppBar(
        title: Text(I18n.of(context).account_change),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => Navigator.of(context, rootNavigator: true)
                .push(MaterialPageRoute(builder: (_) => LoginPage())),
          )
        ],
      ),
    );
  }
}
