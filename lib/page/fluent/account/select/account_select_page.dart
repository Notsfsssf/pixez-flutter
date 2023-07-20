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
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/component/fluent/painter_avatar.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/account.dart';
import 'package:pixez/page/fluent/login/login_page.dart';

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
    return Observer(builder: (context) {
      return ContentDialog(
        content: ListView.builder(
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
                  ? Icon(FluentIcons.check_mark)
                  : IconButton(
                      icon: Icon(FluentIcons.delete),
                      onPressed: () {
                        accountStore.deleteSingle(accountPersist.id!);
                      },
                    ),
              onPressed: () async {
                if (accountStore.accounts.indexOf(accountStore.now) != index) {
                  await accountStore.select(index);
                  setState(() {});
                }
              },
            );
          },
          itemCount: accountStore.accounts.length,
        ),
        title: PageHeader(
          title: Text(I18n.of(context).account_change),
          commandBar: CommandBar(
              mainAxisAlignment: MainAxisAlignment.end,
              primaryItems: [
                CommandBarButton(
                  icon: Icon(FluentIcons.add),
                  onPressed: () => Leader.push(
                    context,
                    LoginPage(),
                    icon: Icon(FluentIcons.add),
                    title: Text(I18n.of(context).login),
                  ),
                )
              ]),
        ),
        actions: [
          FilledButton(
            child: Text(I18n.of(context).ok),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      );
    });
  }
}
