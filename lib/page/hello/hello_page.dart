import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pixez/models/account.dart';

class HelloPage extends StatefulWidget {
  @override
  _HelloPageState createState() => _HelloPageState();
}

class _HelloPageState extends State<HelloPage> {
  @override
  Future initState() async {
    // TODO: implement initState
    super.initState();
    AccountProvider accountProvider = new AccountProvider();
    await accountProvider.open();
    List list = await accountProvider.getAllAccount();
    if(list.length<=0){
      Navigator.of(context).pushNamed('/login');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("w"),),
    );
  }
}
