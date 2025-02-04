import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/glance_illust_persist.dart';
import 'package:pixez/page/history/history_store.dart';

class DataExportPage extends StatefulWidget {
  const DataExportPage({super.key});

  @override
  State<DataExportPage> createState() => _DataExportPageState();
}

class _DataExportPageState extends State<DataExportPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(I18n.of(context).app_data),
      ),
      body: Card(
        margin: EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Builder(builder: (context) {
                return ListTile(
                  title: Text(I18n.of(context).export_title),
                  subtitle: Text(I18n.of(context).export_tag_history),
                  onTap: () async {
                    try {
                      await tagHistoryStore.exportData(context);
                    } catch (e) {
                      print(e);
                    }
                  },
                );
              }),
              ListTile(
                title: Text(I18n.of(context).import_title),
                subtitle: Text(I18n.of(context).import_tag_history),
                onTap: () async {
                  try {
                    await tagHistoryStore.importData();
                  } catch (e) {
                    print(e);
                    BotToast.showText(text: e.toString());
                  }
                },
              ),
              Divider(),
              Builder(builder: (context) {
                return ListTile(
                  title: Text(I18n.of(context).export_title),
                  subtitle: Text(I18n.of(context).export_bookmark_tag),
                  onTap: () async {
                    try {
                      await bookTagStore.exportData(context);
                    } catch (e) {
                      print(e);
                    }
                  },
                );
              }),
              ListTile(
                title: Text(I18n.of(context).import_title),
                subtitle: Text(I18n.of(context).import_bookmark_tag),
                onTap: () async {
                  try {
                    await bookTagStore.importData();
                  } catch (e) {
                    print(e);
                    BotToast.showText(text: e.toString());
                  }
                },
              ),
              Divider(),
              Consumer(builder: (context, ref, widget) {
                return ListTile(
                  title: Text(I18n.of(context).export_title),
                  subtitle: Text(I18n.of(context).export_illust_history),
                  onTap: () async {
                    try {
                      await ref.read(historyProvider.notifier).fetch();
                      await ref.read(historyProvider.notifier).exportData(context);
                    } catch (e) {
                      print(e);
                    }
                  },
                );
              }),
              Consumer(builder: (context, ref, widget) {
                return ListTile(
                  title: Text(I18n.of(context).import_title),
                  subtitle: Text(I18n.of(context).import_illust_history),
                  onTap: () async {
                    try {
                      await ref.read(historyProvider.notifier).fetch();
                      await ref.read(historyProvider.notifier).importData();
                    } catch (e) {
                      print(e);
                      BotToast.showText(text: e.toString());
                    }
                  },
                );
              }),
              Divider(),
              Consumer(builder: (context, ref, widget) {
                return ListTile(
                  title: Text(I18n.of(context).export_title),
                  subtitle: Text(I18n.of(context).export_mute_data),
                  onTap: () async {
                    try {
                      await muteStore.export(context);
                    } catch (e) {
                      print(e);
                    }
                  },
                );
              }),
              Consumer(builder: (context, ref, widget) {
                return ListTile(
                  title: Text(I18n.of(context).import_title),
                  subtitle: Text(I18n.of(context).import_mute_data),
                  onTap: () async {
                    try {
                      await muteStore.importFile();
                    } catch (e) {
                      print(e);
                      BotToast.showText(text: e.toString());
                    }
                  },
                );
              }),
              Divider(),
              ListTile(
                title: Text(I18n.of(context).clear_all_cache),
                onTap: () async {
                  try {
                    await _showClearCacheDialog(context);
                  } catch (e) {}
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future _showClearCacheDialog(BuildContext context) async {
    final result = await showDialog(
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(I18n.of(context).clear_all_cache),
            actions: <Widget>[
              TextButton(
                child: Text(I18n.of(context).cancel),
                onPressed: () {
                  Navigator.of(context).pop("CANCEL");
                },
              ),
              TextButton(
                child: Text(I18n.of(context).ok),
                onPressed: () {
                  Navigator.of(context).pop("OK");
                },
              ),
            ],
          );
        },
        context: context);
    switch (result) {
      case "OK":
        {
          try {
            Directory tempDir = await getTemporaryDirectory();
            tempDir.deleteSync(recursive: true);
            cleanGlanceData();
          } catch (e) {}
        }
        break;
    }
  }

  void cleanGlanceData() async {
    GlanceIllustPersistProvider glanceIllustPersistProvider =
        GlanceIllustPersistProvider();
    await glanceIllustPersistProvider.open();
    await glanceIllustPersistProvider.deleteAll();
    await glanceIllustPersistProvider.close();
  }
}
