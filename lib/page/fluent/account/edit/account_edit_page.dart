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
import 'package:pixez/er/leader.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/page/account/edit/account_edit_store.dart';
import 'package:pixez/page/fluent/webview/account_deletion_webview_page.dart';

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
    return ScaffoldPage(
      header: PageHeader(
        title: Text(I18n.of(context).account_message),
        commandBar: CommandBar(primaryItems: [
          CommandBarButton(
            icon: Icon(FluentIcons.save),
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
                          leading: Icon(FluentIcons.error),
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
                showSnackbar(
                    context,
                    Snackbar(
                      content: Text('${_accountEditStore.errorString}'),
                    ));
              }
            },
          )
        ]),
      ),
      content: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            InfoLabel(
              label: 'Account',
              child: TextBox(
                controller: _accountController,
                enabled: false,
                placeholder: 'Account',
              ),
            ),
            InfoLabel(
              label: I18n.of(context).current_password,
              child: TextBox(
                obscureText: _obscureText,
                controller: _oldPasswordController,
                placeholder: I18n.of(context).current_password,
                suffix: IconButton(
                    icon: Icon(
                      _obscureText
                          ? FluentIcons.show_visual_filter
                          : FluentIcons.hide_visual_filter,
                    ),
                    onPressed: _toggle),
              ),
            ),
            InfoLabel(
              label: I18n.of(context).new_password,
              child: TextBox(
                controller: _passwordController,
                placeholder: I18n.of(context).new_password,
              ),
            ),
            InfoLabel(
              label: 'Email',
              child: TextBox(
                controller: _emailController,
                placeholder: 'Email',
              ),
            ),
            IconButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (ctx) {
                      return ContentDialog(
                        title: Text("${I18n.of(ctx).account_deletion}?"),
                        content:
                            Text("${I18n.of(ctx).account_deletion_subtitle}"),
                        actions: [
                          HyperlinkButton(
                              onPressed: () async {
                                Navigator.of(ctx).pop();
                                await accountStore.deleteAll();
                                final result = await Leader.push(
                                  context,
                                  AccountDeletionPage(),
                                  icon: Icon(FluentIcons.account_management),
                                  title:
                                      Text(I18n.of(context).account_deletion),
                                );
                                Navigator.of(context).pop();
                              },
                              child: Text(I18n.of(ctx).ok)),
                          HyperlinkButton(
                              onPressed: () {
                                Navigator.of(ctx).pop();
                              },
                              child: Text(I18n.of(ctx).cancel)),
                        ],
                      );
                    });
              },
              icon: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      I18n.of(context).account_deletion,
                      style: FluentTheme.of(context).typography.title,
                    ),
                    Icon(FluentIcons.navigate_forward)
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
