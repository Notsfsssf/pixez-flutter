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

import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pixez/generated/l10n.dart';
import 'package:pixez/page/directory/directory_store.dart';

class DirectoryPage extends StatefulWidget {
  @override
  _DirectoryPageState createState() => _DirectoryPageState();
}

class _DirectoryPageState extends State<DirectoryPage> {
  DirectoryStore directoryStore = DirectoryStore();

  @override
  void initState() {
    super.initState();
    _initMethod();
    final dispose = reaction((_) => directoryStore.checkSuccess, (value) {
      if (value) Navigator.of(context).pop(directoryStore.path);
    });
    dispose();
  }

  Future<void> _initMethod() async {
    Map<Permission, PermissionStatus> statuses =
        await [Permission.storage].request();
    if (statuses[0] == PermissionStatus.denied) {
      BotToast.showText(text: '未取得传统授权，无法获得目录');
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(I18n.of(context).choose_directory),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.undo),
              onPressed: () {
                directoryStore.undo();
              }),
          IconButton(
              icon: Icon(Icons.check),
              onPressed: () async {
                if (directoryStore.path == '/storage/emulated/0') return;
                await directoryStore.check();
                Navigator.of(context).pop(directoryStore.path);
              })
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Observer(builder: (_) {
            return ListTile(
              title: Text(directoryStore.path ?? ""),
            );
          }),
          ListTile(
            leading: Icon(Icons.arrow_upward),
            title: Text("..."),
            onTap: () {
              directoryStore.backFolder();
            },
          ),
          Expanded(
            child: Observer(builder: (_) {
              final list = directoryStore.list;
              if (list.isNotEmpty)
                return Container(
                    child: ListView.builder(
                        itemCount: list.length,
                        itemBuilder: (context, index) {
                          FileSystemEntity fileSystemEntity = list[index];
                          return ListTile(
                            leading: fileSystemEntity is Directory
                                ? Icon(Icons.folder)
                                : Icon(Icons.attach_file),
                            title: Text(fileSystemEntity.path.split("/").last),
                            onTap: () {
                              if (fileSystemEntity is Directory) {
                                directoryStore.enterFolder(fileSystemEntity);
                              }
                            },
                          );
                        }));
              else
                return Container();
            }),
          ),
        ],
      ),
    );
  }
}
