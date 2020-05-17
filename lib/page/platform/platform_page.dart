import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/generated/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/page/directory/directory_page.dart';
import 'package:pixez/page/hello/setting/save_format_page.dart';
import 'package:pixez/store/save_store.dart';

class PlatformPage extends StatefulWidget {
  @override
  _PlatformPageState createState() => _PlatformPageState();
}

class _PlatformPageState extends State<PlatformPage> {
  String path = "";
  @override
  void initState() {
    super.initState();
    userSetting.getPath();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Platform Setting"),
      ),
      body: Container(
        child: Observer(builder: (_) {
          return ListView(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.folder),
                title: Text(I18n.of(context).Save_path),
                subtitle: Text(userSetting.path ?? ""),
                onTap: () async {
                  String result =
                      await Navigator.of(context, rootNavigator: true).push(
                          MaterialPageRoute(
                              builder: (context) => DirectoryPage()));
                  if (result != null) userSetting.setPath(result);
                },
              ),
              ListTile(
                leading: Icon(Icons.format_align_left),
                title: Text(I18n.of(context).Save_format),
                subtitle: Text(userSetting.format ?? ""),
                onTap: () async {
                  String result =
                      await Navigator.of(context, rootNavigator: true).push(
                          MaterialPageRoute(
                              builder: (context) => SaveFormatPage()));
                  if (result != null) {
                    userSetting.setFormat(result);
                  }
                  // if (result != null) userSetting.setPath(result);
                },
              )
            ],
          );
        }),
      ),
    );
  }
}
