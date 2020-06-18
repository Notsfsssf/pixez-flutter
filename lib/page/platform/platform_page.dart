import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:package_info/package_info.dart';
import 'package:pixez/generated/l10n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/page/directory/directory_page.dart';
import 'package:pixez/page/hello/setting/save_format_page.dart';

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
    initVoid();
  }

  initVoid() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      version = packageInfo.version;
    });
  }

  String version = "";
  bool singleFolder = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ListTile(
          title: Text("Platform Setting"),
          subtitle: Text(
            "For Android",
            style: TextStyle(color: Colors.greenAccent),
          ),
        ),
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
              ),
              Observer(
                builder: (_) {
                  return SwitchListTile(
                    secondary: Icon(Icons.folder_shared),
                    onChanged: (bool value) async {
                      await userSetting.setSingleFolder(value);
                    },
                    title: Text(I18n.of(context).Separate_Folder),
                    subtitle: Text(I18n.of(context).Separate_Folder_Message),
                    value: userSetting.singleFolder,
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.info),
                title: Text("Version"),
                subtitle: Text("0.0.2"),
                onTap: () async {},
              )
            ],
          );
        }),
      ),
    );
  }
}
