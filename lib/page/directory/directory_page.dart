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
import 'package:pixez/i18n.dart';
import 'package:pixez/page/directory/directory_store.dart';

class DirectoryPage extends StatefulWidget {
  final String? initPath;

  const DirectoryPage({Key? key, this.initPath}) : super(key: key);

  @override
  _DirectoryPageState createState() => _DirectoryPageState();
}

class _DirectoryPageState extends State<DirectoryPage> {
  late DirectoryStore directoryStore;

  @override
  void initState() {
    directoryStore = DirectoryStore();
    super.initState();
    _initMethod();
    final dispose = reaction((_) => directoryStore.checkSuccess, (value) {
      if (value) Navigator.of(context).pop(directoryStore.path);
    });
    dispose();
  }

  Future<void> _initMethod() async {
    PermissionStatus statuses =
        await Permission.storage.request();
    if (statuses == PermissionStatus.denied) {
      BotToast.showText(text: I18n.of(context).permission_denied);
      Navigator.of(context).pop();
    }
    directoryStore.init(widget.initPath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          if (directoryStore.path == '/storage/emulated/0') return;
          await directoryStore.check();
          Navigator.of(context).pop(directoryStore.path);
        },
        label: Text(I18n.of(context).ok),
        icon: Icon(Icons.check),
      ),
      appBar: AppBar(
        title: Text(I18n.of(context).choose_directory),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.undo),
              onPressed: () {
                directoryStore.undo();
              }),
          IconButton(
              icon: Icon(Icons.create_new_folder_outlined),
              onPressed: () async {
                final result = await showDialog(
                    context: context,
                    builder: (context) {
                      final controller = TextEditingController();
                      return AlertDialog(
                        title: Text(I18n.of(context).create_folder),
                        content: TextFormField(
                          controller: controller,
                          decoration: InputDecoration(),
                        ),
                        actions: [
                          TextButton(
                            child: Text(I18n.of(context).cancel),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: Text(I18n.of(context).ok),
                            onPressed: () {
                              Navigator.of(context).pop(controller.text);
                            },
                          ),
                        ],
                      );
                    });
                if (result != null) {
                  String folderName = result
                      .replaceAll("/", "")
                      .replaceAll("\\", "")
                      .replaceAll(":", "")
                      .replaceAll("*", "")
                      .replaceAll("?", "")
                      .replaceAll(">", "")
                      .replaceAll("|", "")
                      .replaceAll(".", "")
                      .replaceAll("<", "");
                  if (folderName.isEmpty) {
                    return;
                  }
                  Directory directory =
                      Directory('${directoryStore.path}/$result');
                  if (!directory.existsSync()) {
                    directory.createSync(recursive: true);
                    directoryStore.enterFolder(directory);
                  }
                }
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
              list.sort((a, b) => a.path.compareTo(b.path));
              if (list.isNotEmpty)
                return Container(
                    child: ListView.builder(
                        itemCount: list.length,
                        itemBuilder: (context, index) {
                          FileSystemEntity fileSystemEntity = list[index];
                          return Visibility(
                            visible: !(fileSystemEntity.path
                                    .split("/")
                                    .last
                                    .startsWith(".")),
                            child: ListTile(
                              leading: fileSystemEntity is Directory
                                  ? Icon(Icons.folder)
                                  : Icon(Icons.attach_file),
                              title:
                                  Text(fileSystemEntity.path.split("/").last),
                              onTap: () {
                                if (fileSystemEntity is Directory) {
                                  directoryStore.enterFolder(fileSystemEntity);
                                }
                              },
                            ),
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
