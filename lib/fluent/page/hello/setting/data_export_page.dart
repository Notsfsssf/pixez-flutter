import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/models/glance_illust_persist.dart';

class DataExportPage extends StatefulWidget {
  const DataExportPage({super.key});

  @override
  State<DataExportPage> createState() => _DataExportPageState();
}

class _DataExportPageState extends State<DataExportPage> {
  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: PageHeader(
        title: Text(I18n.of(context).app_data),
      ),
      content: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ListTile(
              //   title: Text(I18n.of(context).export_title),
              //   subtitle: Text(I18n.of(context).export_tag_history),
              //   onPressed: () async {
              //     try {
              //       await tagHistoryStore.exportData();
              //     } catch (e) {
              //       print(e);
              //     }
              //   },
              // ),
              // ListTile(
              //   title: Text(I18n.of(context).import_title),
              //   subtitle: Text(I18n.of(context).import_tag_history),
              //   onPressed: () async {
              //     try {
              //       await tagHistoryStore.importData();
              //     } catch (e) {
              //       print(e);
              //       BotToast.showText(text: e.toString());
              //     }
              //   },
              // ),
              // Divider(),
              // ListTile(
              //   title: Text(I18n.of(context).export_title),
              //   subtitle: Text(I18n.of(context).export_bookmark_tag),
              //   onPressed: () async {
              //     try {
              //       await bookTagStore.exportData();
              //     } catch (e) {
              //       print(e);
              //     }
              //   },
              // ),
              // ListTile(
              //   title: Text(I18n.of(context).import_title),
              //   subtitle: Text(I18n.of(context).import_bookmark_tag),
              //   onPressed: () async {
              //     try {
              //       await bookTagStore.importData();
              //     } catch (e) {
              //       print(e);
              //       BotToast.showText(text: e.toString());
              //     }
              //   },
              // ),
              // Divider(),
              ListTile(
                title: Text(I18n.of(context).clear_all_cache),
                onPressed: () async {
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
          return ContentDialog(
            title: Text(I18n.of(context).clear_all_cache),
            actions: <Widget>[
              Button(
                child: Text(I18n.of(context).cancel),
                onPressed: () {
                  Navigator.of(context).pop("CANCEL");
                },
              ),
              Button(
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
