import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:pixez/main.dart';

class DataExportPage extends StatefulWidget {
  const DataExportPage({super.key});

  @override
  State<DataExportPage> createState() => _DataExportPageState();
}

class _DataExportPageState extends State<DataExportPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Data Export"),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text("Export"),
            onTap: () async {
              try {
                await tagHistoryStore.exportData();
              } catch (e) {
                print(e);
              }
            },
          ),
          ListTile(
            title: Text("Import"),
            onTap: () async {
              try {
                await tagHistoryStore.importData();
              } catch (e) {
                print(e);
                BotToast.showText(text: e.toString());
              }
            },
          ),
        ],
      ),
    );
  }
}
