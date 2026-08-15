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
import 'package:material_ui/material_ui.dart';
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

  @override
  void dispose() {
    _passwordController.dispose();
    _oldPasswordController.dispose();
    _emailController.dispose();
    _accountController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_oldPasswordController.text.isEmpty || _emailController.text.isEmpty) {
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
              title: Text("Email format error"),
            ),
          ),
        ),
      );
      return;
    }
    bool success = await _accountEditStore.fetch(
      _emailController.text,
      null,
      _oldPasswordController.text,
      null,
    );
    if (success) {
      if (accountStore.now != null) {
        if (_emailController.text.isNotEmpty) {
          accountStore.now!.mailAddress = _emailController.text;
        }
        accountStore.updateSingle(accountStore.now!);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_accountEditStore.errorString}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _showChangePasswordDialog() async {
    await showDialog(
      context: context,
      builder: (context) => _ChangePasswordDialog(
        oldPasswordController: _oldPasswordController,
        passwordController: _passwordController,
        email: _emailController.text,
        accountEditStore: _accountEditStore,
      ),
    );
  }

  Future<void> _showAccountDeletionDialog() async {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text("${I18n.of(ctx).account_deletion}?"),
          content: Text("${I18n.of(ctx).account_deletion_subtitle}"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: Text(I18n.of(ctx).cancel),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(ctx).pop();
                await accountStore.deleteAll();
                await Leader.push(context, AccountDeletionPage());
                Navigator.of(context).pop();
              },
              child: Text(I18n.of(ctx).ok),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final errorColor = Theme.of(context).colorScheme.error;
    final showTokenExport =
        accountStore.now != null && accountStore.now!.isMailAuthorized == 1;

    return Scaffold(
      appBar: AppBar(
        title: Text(I18n.of(context).account_message),
        actions: <Widget>[IconButton(icon: Icon(Icons.save), onPressed: _save)],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Card(
              margin: EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _accountController,
                          enabled: false,
                          decoration: InputDecoration(
                            hintText: I18n.of(context).account,
                            labelText: I18n.of(context).account,
                          ),
                        ),
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            hintText: 'Email',
                            labelText: 'Email',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (showTokenExport)
              Card(
                margin: const EdgeInsets.fromLTRB(8, 16, 8, 0),
                child: ListTile(
                  leading: Icon(Icons.vpn_key_outlined),
                  title: Text(I18n.of(context).export + " Token"),
                  trailing: Icon(Icons.copy),
                  onTap: () async {
                    Clipboard.setData(
                      ClipboardData(text: accountStore.now!.refreshToken),
                    );
                    BotToast.showText(
                      text: I18n.of(context).copied_to_clipboard,
                    );
                  },
                ),
              ),
            Card(
              margin: const EdgeInsets.fromLTRB(8, 16, 8, 0),
              child: ListTile(
                leading: Icon(Icons.lock_outline),
                title: Text(I18n.of(context).change_password),
                trailing: Icon(Icons.chevron_right),
                onTap: _showChangePasswordDialog,
              ),
            ),
            const SizedBox(height: 24),
            Card(
              margin: EdgeInsets.symmetric(horizontal: 8.0),
              child: ListTile(
                leading: Icon(Icons.delete_outline, color: errorColor),
                title: Text(
                  I18n.of(context).account_deletion,
                  style: TextStyle(color: errorColor),
                ),
                onTap: _showAccountDeletionDialog,
              ),
            ),
            Container(height: MediaQuery.of(context).padding.bottom + 20),
          ],
        ),
      ),
    );
  }
}

class _ChangePasswordDialog extends StatefulWidget {
  final TextEditingController oldPasswordController;
  final TextEditingController passwordController;
  final String email;
  final AccountEditStore accountEditStore;

  const _ChangePasswordDialog({
    required this.oldPasswordController,
    required this.passwordController,
    required this.email,
    required this.accountEditStore,
  });

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  bool _obscureText = true;
  String _errorMessage = "";

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Future<void> _submit() async {
    if (widget.oldPasswordController.text.isEmpty ||
        widget.passwordController.text.isEmpty) {
      return;
    }
    setState(() {
      _errorMessage = "";
    });
    final success = await widget.accountEditStore.fetch(
      widget.email,
      widget.passwordController.text,
      widget.oldPasswordController.text,
      null,
    );
    if (!mounted) return;
    if (success) {
      if (accountStore.now != null) {
        accountStore.now!.passWord = widget.passwordController.text;
        accountStore.updateSingle(accountStore.now!);
      }
      widget.oldPasswordController.text = widget.passwordController.text;
      widget.passwordController.clear();
      Navigator.of(context).pop();
    } else {
      setState(() {
        _errorMessage = widget.accountEditStore.errorString ?? "";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(I18n.of(context).change_password),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            autofocus: true,
            obscureText: _obscureText,
            controller: widget.oldPasswordController,
            decoration: InputDecoration(
              hintText: I18n.of(context).current_password,
              labelText: I18n.of(context).current_password,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: _toggle,
              ),
            ),
          ),
          TextFormField(
            obscureText: _obscureText,
            controller: widget.passwordController,
            decoration: InputDecoration(
              hintText: I18n.of(context).new_password,
              labelText: I18n.of(context).new_password,
            ),
            onFieldSubmitted: (_) => _submit(),
          ),
          if (_errorMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.2,
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _errorMessage,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(I18n.of(context).cancel),
        ),
        FilledButton(onPressed: _submit, child: Text(I18n.of(context).ok)),
      ],
    );
  }
}
