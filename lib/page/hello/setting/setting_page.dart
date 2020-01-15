import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pixez/generated/i18n.dart';
import 'package:pixez/page/history/history_page.dart';

class SettingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.history),
                title: Text(I18n.of(context).History),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) {
                    return HistoryPage();
                  }));
                },
              ),

            ],
          ),
        ),
      ),
    );
  }
}
