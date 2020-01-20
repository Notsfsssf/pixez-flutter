import 'package:flutter/material.dart';
import 'package:pixez/generated/i18n.dart';

class AccountEditPage extends StatefulWidget {
  @override
  _AccountEditPageState createState() => _AccountEditPageState();
}

class _AccountEditPageState extends State<AccountEditPage> {
  TextEditingController _passwordController, _emailController;
  @override
  void initState() {
    _passwordController = TextEditingController();
    _emailController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(I18n.of(context).Account_Message),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            TextFormField(
              controller: _passwordController,
            ),
            TextFormField(
              controller: _emailController,
            ),
          ],
        ),
      ),
    );
  }
}
