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

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/generated/l10n.dart';
import 'package:pixez/main.dart';

class SaveFormatPage extends StatefulWidget {
  @override
  _SaveFormatPageState createState() => _SaveFormatPageState();
}

class _SaveFormatPageState extends State<SaveFormatPage> {
  late TextEditingController _textEditingController;
  final badText = ['/', '\\', ':', ' '];

  @override
  void initState() {
    _textEditingController = TextEditingController(text: userSetting.format);
    super.initState();
    _textEditingController.addListener(() {
      bool needBack = false;
      String beforeText = _textEditingController.text;
      badText.forEach((element) {
        if (_textEditingController.text.contains(element)) {
          needBack = true;
          beforeText = beforeText.replaceAll(element, "");
        }
      });
      if (needBack) {
        BotToast.showText(text: "illegal text");
        _textEditingController.text = beforeText;
      }
    });
  }

  @override
  void dispose() {
    _textEditingController?.dispose();
    super.dispose();
  }

  _buildActionText(String text) => ActionChip(
      label: Text("$text"),
      onPressed: () {
        if (_textEditingController.selection.end == -1) return;
        var insertText = "{$text}";
        if (text == "_") insertText = "_";
        final textSelection = _textEditingController.selection;
        _textEditingController.text = _textEditingController.text
            .replaceRange(textSelection.start, textSelection.end, insertText);
        _textEditingController.selection = textSelection.copyWith(
            baseOffset: textSelection.start + insertText.length,
            extentOffset: textSelection.start + insertText.length);
      });
  String intialFormat = "{illust_id}_p{part}";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(I18n.of(context).save_format),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () async {
                _textEditingController.text = intialFormat;
                await userSetting.setFormat(intialFormat);
              }),
          IconButton(
              icon: Icon(Icons.save),
              onPressed: () {
                var needBack = false;
                badText.forEach((element) {
                  if (_textEditingController.text.contains(element)) {
                    needBack = true;
                  }
                });
                if (!_textEditingController.text.contains('{part}')) {
                  BotToast.showText(
                      text: I18n.of(context)
                          .save_format_lose_part_warning('{part}'));
                  return;
                }
                if (_textEditingController.text.isNotEmpty && !needBack)
                  Navigator.of(context).pop(_textEditingController.text);
              }),
        ],
      ),
      body: Container(
        child: ListView(children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
                controller: _textEditingController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Input File Name Format',
                  labelText: 'File Name Format',
                )),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              spacing: 4.0,
              children: <Widget>[
                _buildActionText("title"),
                _buildActionText("_"),
                _buildActionText("part"),
                _buildActionText("illust_id"),
                _buildActionText("user_id"),
                _buildActionText("user_name"),
              ],
            ),
          ),
          Observer(builder: (_) {
            return SwitchListTile(
              title: Text(I18n.of(context).clear_old_format_file),
              subtitle: Text(I18n.of(context).clear_old_format_file_message),
              onChanged: (bool value) {
                userSetting.setIsClearnOldFormatFile(value);
              },
              value: userSetting.isClearOldFormatFile,
            );
          }),
          DataTable(
            columns: <DataColumn>[
              DataColumn(label: Text("Name")),
              DataColumn(label: Text("Result")),
            ],
            rows: <DataRow>[
              DataRow(cells: [
                DataCell(Text('{illust_id}')),
                DataCell(Text(I18n.of(context).illust_id)),
              ]),
              DataRow(cells: [
                DataCell(Text('{title}')),
                DataCell(Text(I18n.of(context).title)),
              ]),
              DataRow(cells: [
                DataCell(Text('{user_id}')),
                DataCell(Text(I18n.of(context).painter_id)),
              ]),
              DataRow(cells: [
                DataCell(Text('{user_name}')),
                DataCell(Text(I18n.of(context).painter_name)),
              ]),
              DataRow(cells: [
                DataCell(Text('part')),
                DataCell(Text(I18n.of(context).which_part)),
              ]),
            ],
          )
        ]),
      ),
    );
  }
}
