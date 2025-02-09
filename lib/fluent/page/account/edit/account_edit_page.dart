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

import 'package:bot_toast/bot_toast.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/page/account/edit/account_edit_store.dart';
import 'package:pixez/fluent/page/webview/account_deletion_webview_page.dart';

class AccountEditPage extends StatefulWidget {
  @override
  _AccountEditPageState createState() => _AccountEditPageState();
}

class _AccountEditPageState extends State<AccountEditPage> {
  late TextEditingController _passwordController,
      _oldPasswordController,
      _emailController,
      _accountController;
  AccountEditStore _accountEditStore = AccountEditStore();

  @override
  void initState() {
    _passwordController = TextEditingController();
    _emailController = TextEditingController();
    _accountController = TextEditingController();
    _oldPasswordController = TextEditingController();
    if (accountStore.now != null) {
      if (accountStore.now!.isMailAuthorized != 1) {
        _oldPasswordController.text = accountStore.now!.passWord;
      }
      _accountController.text = accountStore.now!.account;
      _emailController.text = accountStore.now!.mailAddress;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: Text(I18n.of(context).account_message),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0)
                .copyWith(top: 0, bottom: 4.0),
            child: InfoLabel(
              label: I18n.of(context).account,
              child: TextBox(
                controller: _accountController,
                enabled: false,
                placeholder: I18n.of(context).account,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
            child: InfoLabel(
              label: I18n.of(context).current_password,
              child: PasswordBox(
                controller: _oldPasswordController,
                placeholder: I18n.of(context).current_password,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
            child: InfoLabel(
              label: I18n.of(context).new_password,
              child: PasswordBox(
                controller: _passwordController,
                placeholder: I18n.of(context).new_password,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
            child: InfoLabel(
              label: 'Email',
              child: TextBox(
                controller: _emailController,
                placeholder: 'Email',
              ),
            ),
          ),
          if (accountStore.now != null &&
              accountStore.now!.isMailAuthorized == 1)
            ListTile(
              onPressed: () async {
                Clipboard.setData(
                    ClipboardData(text: accountStore.now!.refreshToken));
                BotToast.showText(text: "Copied to clipboard");
              },
              title: Text("Token export"),
            ),
          ListTile(
            title: Text(I18n.of(context).account_deletion),
            trailing: Icon(FluentIcons.open_in_new_window),
            onPressed: () => showDialog(
              context: context,
              useRootNavigator: false,
              builder: (ctx) {
                return ContentDialog(
                  title: Text("${I18n.of(ctx).account_deletion}?"),
                  content: Text("${I18n.of(ctx).account_deletion_subtitle}"),
                  actions: [
                    Button(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                      },
                      child: Text(I18n.of(ctx).cancel),
                    ),
                    FilledButton(
                      onPressed: () async {
                        Navigator.of(ctx).pop();
                        await accountStore.deleteAll();
                        await Leader.push(
                          context,
                          AccountDeletionPage(),
                          icon: Icon(FluentIcons.account_management),
                          title: Text(I18n.of(context).account_deletion),
                        );
                        Navigator.of(context).pop();
                      },
                      child: Text(I18n.of(ctx).ok),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      actions: [
        Button(
          child: Text(I18n.of(context).cancel),
          onPressed: () => Navigator.of(context).pop(),
        ),
        FilledButton(
          child: Text(I18n.of(context).save),
          onPressed: () async {
            if (_oldPasswordController.text.isEmpty ||
                _emailController.text.isEmpty) {
              Navigator.of(context).pop();
              return;
            }
            if (_emailController.text.isNotEmpty &&
                !_emailController.text.contains('@')) {
              BotToast.showCustomText(
                toastBuilder: (_) => Align(
                  alignment: Alignment(0, 0.8),
                  child: Card(
                    child: ListTile(
                        leading: Icon(FluentIcons.error),
                        title: Text("Email format error")),
                  ),
                ),
              );
              Navigator.of(context).pop();
              return;
            }
            bool success = await _accountEditStore.fetch(
                (_emailController.value.text.isEmpty
                    ? null
                    : _emailController.value.text)!,
                _passwordController.value.text.isEmpty
                    ? null
                    : _passwordController.value.text,
                _oldPasswordController.value.text,
                null);
            if (success) {
              if (accountStore.now != null) {
                if (_passwordController.text.isNotEmpty) {
                  accountStore.now!.passWord = _passwordController.text;
                }
                if (_emailController.text.isNotEmpty) {
                  accountStore.now!.mailAddress = _emailController.text;
                }
                accountStore.updateSingle(accountStore.now!);
              }
            } else {
              displayInfoBar(context,
                  builder: (context, VoidCallback) => InfoBar(
                        title: Text('Error'),
                        content: Text('${_accountEditStore.errorString}'),
                      ));
            }
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
