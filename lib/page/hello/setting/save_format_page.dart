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
import 'package:pixez/generated/l10n.dart';
import 'package:pixez/main.dart';

class SaveFormatPage extends StatefulWidget {
  @override
  _SaveFormatPageState createState() => _SaveFormatPageState();
}

class _SaveFormatPageState extends State<SaveFormatPage> {
  TextEditingController _textEditingController;
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
        BotToast.showText(Text(I18n.of(context).Format_toast)));
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
        title: Text(I18n.of(context).Save_format),
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
                  hintText: I18n.of(context).Format_inputbox_tip_inline,
                  labelText: I18n.of(context).Format_inputbox_tip,
                )),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              spacing: 4.0,
              children: <Widget>[
                _buildActionText(I18n.of(context).Format_user_name),
                _buildActionText(I18n.of(context).Format_user_id),
                _buildActionText(I18n.of(context).Format_illust_name),
                _buildActionText(I18n.of(context).Format_illust_id),
                _buildActionText(I18n.of(context).Format_illust_index),
                _buildActionText("_"),
              ],
            ),
          ),
          DataTable(
            columns: <DataColumn>[
              DataColumn(label: Text(I18n.of(context).Format_name)),
              DataColumn(label: Text(I18n.of(context).Format_result)),
            ],
            rows: <DataRow>[
              DataRow(cells: [
                DataCell(Text('{${Format_user_name}}')),
                DataCell(Text(I18n.of(context).Illust_id)),
              ]),
              DataRow(cells: [
                DataCell(Text('{${Format_user_id}}')),
                DataCell(Text(I18n.of(context).Title)),
              ]),
              DataRow(cells: [
                DataCell(Text('{${Format_illust_name}}')),
                DataCell(Text(I18n.of(context).Painter_id)),
              ]),
              DataRow(cells: [
                DataCell(Text('{${Format_illust_id}}')),
                DataCell(Text(I18n.of(context).Painter_Name)),
              ]),
              DataRow(cells: [
                DataCell(Text('{${Format_illust_index}}')),
                DataCell(Text(I18n.of(context).Which_part)),
              ]),
            ],
          )
        ]),
      ),
    );
  }
}
