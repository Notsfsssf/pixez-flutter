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
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/page/account/edit/account_edit_store.dart';
import 'package:pixez/page/webview/account_deletion_webview_page.dart';

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

  bool _obscureText = true;

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(I18n.of(context).account_message),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () async {
              if (_oldPasswordController.text.isEmpty ||
                  _emailController.text.isEmpty) {
                return;
              }
              if (_emailController.text.isNotEmpty &&
                  !_emailController.text.contains('@')) {
                BotToast.showCustomText(
                  toastBuilder: (_) => Align(
                    alignment: Alignment(0, 0.8),
                    child: Card(
                      child: ListTile(
                          leading: Icon(Icons.error),
                          title: Text("Email format error")),
                    ),
                  ),
                );
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
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('${_accountEditStore.errorString}'),
                  backgroundColor: Colors.red,
                ));
              }
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Theme(
          data: ThemeData(
              primaryColor: Theme.of(context).colorScheme.secondary,
              brightness: Theme.of(context).brightness),
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _accountController,
                enabled: false,
                decoration: InputDecoration(
                  hintText: I18n.of(context).account,
                  labelText: I18n.of(context).account,
                ),
              ),
              TextFormField(
                obscureText: _obscureText,
                controller: _oldPasswordController,
                decoration: InputDecoration(
                  hintText: I18n.of(context).current_password,
                  labelText: I18n.of(context).current_password,
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: _toggle),
                ),
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  hintText: I18n.of(context).new_password,
                  labelText: I18n.of(context).new_password,
                ),
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  hintText: 'Email',
                  labelText: 'Email',
                ),
              ),
              if (accountStore.now != null &&
                  accountStore.now!.isMailAuthorized == 1)
                InkWell(
                  onTap: () async {
                    Clipboard.setData(
                        ClipboardData(text: accountStore.now!.refreshToken));
                    BotToast.showText(text: "Copied to clipboard");
                  },
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Token export",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Icon(Icons.arrow_forward_ios)
                      ],
                    ),
                  ),
                ),
              InkWell(
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (ctx) {
                        return AlertDialog(
                          title: Text("${I18n.of(ctx).account_deletion}?"),
                          content:
                              Text("${I18n.of(ctx).account_deletion_subtitle}"),
                          actions: [
                            TextButton(
                                onPressed: () async {
                                  Navigator.of(ctx).pop();
                                  await accountStore.deleteAll();
                                  await Leader.push(
                                      context, AccountDeletionPage());
                                  Navigator.of(context).pop();
                                },
                                child: Text(I18n.of(ctx).ok)),
                            TextButton(
                                onPressed: () {
                                  Navigator.of(ctx).pop();
                                },
                                child: Text(I18n.of(ctx).cancel)),
                          ],
                        );
                      });
                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        I18n.of(context).account_deletion,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Icon(Icons.arrow_forward_ios)
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
