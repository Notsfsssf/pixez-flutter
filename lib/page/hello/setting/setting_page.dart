import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pixez/generated/i18n.dart';
import 'package:pixez/page/history/history_page.dart';

class SettingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(I18n.of(context).Setting),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.history),
                title: Text(I18n.of(context).History),
                onTap: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (BuildContext context) {
                    return HistoryPage();
                  }));
                },
              ),
              ListTile(
                onTap: () async {
                  final result = await showCupertinoDialog(
                      builder: (BuildContext context) {
                        return CupertinoAlertDialog(
                          title: Text("Warning"),
                          content: Text("Clear all tempFile?"),
                          actions: <Widget>[
                            CupertinoDialogAction(
                              child: Text("OK"),
                              onPressed: () {
                                Navigator.of(context).pop("OK");
                              },
                            ),
                            CupertinoDialogAction(
                              child: Text("CANCEL"),
                              onPressed: () {
                                Navigator.of(context).pop("CANCEL");
                              },
                              isDestructiveAction: true,
                            )
                          ],
                        );
                      },
                      context: context);
                  switch (result) {
                    case "OK":
                      {
                        Directory tempDir = await getTemporaryDirectory();
                        tempDir.deleteSync(recursive: true);
                      }
                      break;
                  }
                },
                title: Text(I18n.of(context).Clear),
                leading: Icon(Icons.clear),
              )
            ],
          ),
        ),
      ),
    );
  }
}
