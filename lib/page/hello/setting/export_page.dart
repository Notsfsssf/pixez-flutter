import 'dart:convert';
import 'dart:typed_data';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:pixez/document_plugin.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/tags.dart';

class ExportPage extends StatefulWidget {
  const ExportPage({super.key});

  @override
  State<ExportPage> createState() => _ExportPageState();
}

class _ExportPageState extends State<ExportPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(children: [
        ListTile(
          title: Text("Export tag history"),
          onTap: () {
            final tags = tagHistoryStore.tags;
            List<TagsPersist> tagsPersist = tags.toList();
            String json = jsonEncode(tagsPersist);
            final data = Uint8List.fromList(json.codeUnits);
            DocumentPlugin.openSave(data, "export_tag_history.json");
          },
        ),
        ListTile(
          title: Text("Import tag history"),
          onTap: () async {
            Uint8List uint8list = Uint8List(10);
            String json = String.fromCharCodes(uint8list);
            List<TagsPersist> tagsPersist = jsonDecode(json);
            for (var element in tagsPersist) {
              await tagHistoryStore.insert(element);
            }
            BotToast.showText(text: "Ok");
          },
        ),
      ]),
    );
  }
}
