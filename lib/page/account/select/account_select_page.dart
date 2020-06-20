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
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixez/component/painter_avatar.dart';
import 'package:pixez/generated/l10n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/account.dart';
import 'package:pixez/page/account/select/account_select_bloc.dart';
import 'package:pixez/page/account/select/account_select_event.dart';
import 'package:pixez/page/account/select/account_select_state.dart';
import 'package:pixez/page/login/login_page.dart';

class AccountSelectPage extends StatefulWidget {
  @override
  _AccountSelectPageState createState() => _AccountSelectPageState();
}

class _AccountSelectPageState extends State<AccountSelectPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<AccountSelectBloc>(
      child: Scaffold(
        body: BlocListener<AccountSelectBloc, AccountSelectState>(
          listener: (context, state) {
            if (state is SelectState) {
              accountStore.fetch();
            }
          },
          child: BlocBuilder<AccountSelectBloc, AccountSelectState>(
              builder: (context, snapshot) {
            if (snapshot is AllAccountSelectState) {
              return Container(
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    AccountPersist accountPersist = snapshot.accounts[index];
                    return ListTile(
                      leading: PainterAvatar(
                          url: snapshot.accounts[index].userImage),
                      title: Text(accountPersist.name),
                      subtitle: Text(accountPersist.mailAddress),
                      trailing: snapshot.selectNum == index
                          ? Icon(Icons.check)
                          : IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                BlocProvider.of<AccountSelectBloc>(context).add(
                                    DeleteAccountSelectEvent(
                                        accountPersist.id));
                              },
                            ),
                      onTap: () {
                        if (snapshot.selectNum != index) {
                          BlocProvider.of<AccountSelectBloc>(context)
                              .add(SelectAccountSelectEvent(index));
                        }
                      },
                    );
                  },
                  itemCount: snapshot.accounts.length,
                ),
              );
            }
            return Container();
          }),
        ),
        appBar: AppBar(
          title: Text(I18n.of(context).Account_change),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () => Navigator.of(context, rootNavigator: true)
                  .push(MaterialPageRoute(builder: (_) => LoginPage())),
            )
          ],
        ),
      ),
      create: (BuildContext context) =>
          AccountSelectBloc()..add(FetchAllAccountSelectEvent()),
    );
  }
}
