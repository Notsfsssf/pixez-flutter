import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixez/bloc/account_bloc.dart';
import 'package:pixez/bloc/account_event.dart';
import 'package:pixez/bloc/account_state.dart';
import 'package:pixez/generated/i18n.dart';
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
    var state1 = BlocProvider.of<AccountBloc>(context).state;
    if (state1 is HasUserState) {
      _oldPasswordController.text = state1.list.passWord;
      _accountController.text = state1.list.account;
      _emailController.text = state1.list.mailAddress;
    }

    super.initState();
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
                            title:Text("Email format error")
                          ),
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
                final bloc = BlocProvider.of<AccountBloc>(context);
                var state = bloc.state;
                if (state is HasUserState) {
                  if (_passwordController.text.isNotEmpty) {
                    state.list.passWord = _passwordController.text;
                  }
                  if (_emailController.text.isNotEmpty) {
                    state.list.mailAddress = _emailController.text;
                  }
                  bloc.add(UpdateAccountEvent(state.list));
                }
              }
              if (now is FailAccountEditState) {
                Scaffold.of(context).showSnackBar(SnackBar(
                  content: Text('error'),
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
                      decoration: const InputDecoration(
                        hintText: 'Account',
                        labelText: 'Account',
                      ),
                    ),
                    TextFormField(
                      enabled: false,
                      controller: _oldPasswordController,
                      decoration: const InputDecoration(
                          hintText: 'CurrentPassword',
                          labelText: 'CurrentPassword',
                          enabled: false),
                    ),
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        hintText: 'New PassWord',
                        labelText: 'New PassWord',
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
