import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
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
    final dispose = reaction((_) => directoryStore.checkSuccess, (value) {
      if (value) Navigator.of(context).pop(directoryStore.path);
    });
    dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(I18n.of(context).Choose_directory),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.undo),
              onPressed: () {
                directoryStore.undo();
              }),
          IconButton(
              icon: Icon(Icons.check),
              onPressed: () async {
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
