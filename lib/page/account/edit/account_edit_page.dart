import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixez/bloc/account_bloc.dart';
import 'package:pixez/bloc/account_event.dart';
import 'package:pixez/bloc/account_state.dart';
import 'package:pixez/generated/l10n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/page/account/edit/bloc/account_edit_bloc.dart';
import 'package:pixez/page/account/edit/bloc/account_edit_event.dart';
import 'package:pixez/page/account/edit/bloc/account_edit_state.dart';

class AccountEditPage extends StatefulWidget {
  @override
  _AccountEditPageState createState() => _AccountEditPageState();
}

class _AccountEditPageState extends State<AccountEditPage> {
  TextEditingController _passwordController,
      _oldPasswordController,
      _emailController,
      _accountController;
  @override
  void initState() {
    _passwordController = TextEditingController();
    _emailController = TextEditingController();
    _accountController = TextEditingController();
    _oldPasswordController = TextEditingController();
    if (accountStore.now != null) {
      _oldPasswordController.text = accountStore.now.passWord;
      _accountController.text = accountStore.now.account;
      _emailController.text = accountStore.now.mailAddress;
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
    return BlocProvider<AccountEditBloc>(
      child:
          BlocBuilder<AccountEditBloc, AccountEditState>(condition: (pre, now) {
        return false;
      }, builder: (context, snapshot) {
        return Scaffold(
          appBar: AppBar(
            title: Text(I18n.of(context).Account_Message),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.save),
                onPressed: () {
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
                  BlocProvider.of<AccountEditBloc>(context)
                      .add(FetchAccountEditEvent(
                    oldPassword: _oldPasswordController.value.text,
                    newPassword: _passwordController.value.text.isEmpty
                        ? null
                        : _passwordController.value.text,
                    newMailAddress: _emailController.value.text.isEmpty
                        ? null
                        : _emailController.value.text,
                  ));
                },
              )
            ],
          ),
          body: BlocListener<AccountEditBloc, AccountEditState>(
            listener: (context, now) {
              if (now is SuccessAccountEditState) {
                if (accountStore.now != null) {
                  if (_passwordController.text.isNotEmpty) {
                    accountStore.now.passWord = _passwordController.text;
                  }
                  if (_emailController.text.isNotEmpty) {
                    accountStore.now.mailAddress = _emailController.text;
                  }
                  accountStore.updateSingle(accountStore.now);
                }
              }
              if (now is FailAccountEditState) {
                Scaffold.of(context).showSnackBar(SnackBar(
                  content: Text('${now.e}'),
                  backgroundColor: Colors.red,
                ));
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      controller: _accountController,
                      enabled: false,
                      decoration: InputDecoration(
                        hintText: 'Account',
                        labelText: 'Account',
                      ),
                    ),
                    TextFormField(
                      obscureText: _obscureText,
                      controller: _oldPasswordController,
                      decoration: InputDecoration(
                        hintText: I18n
                            .of(context)
                            .Current_Password,
                        labelText: I18n
                            .of(context)
                            .Current_Password,
                        border: InputBorder.none,
                        suffixIcon: IconButton(icon: Icon(
                          _obscureText
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ), onPressed: _toggle),
                      ),
                    ),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        hintText: I18n
                            .of(context)
                            .New_Password,
                        labelText: I18n
                            .of(context)
                            .New_Password,
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
            ),
          ),
        );
      }),
      create: (BuildContext context) => AccountEditBloc(),
    );
  }
}
