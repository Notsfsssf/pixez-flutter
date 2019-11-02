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
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/i18n.dart';
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
    _textEditingController.dispose();
    super.dispose();
  }

  _buildActionText(String text) => Button(
        child: Text("$text"),
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
        },
      );
  String intialFormat = "{illust_id}_p{part}";

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: PageHeader(
        title: Text(I18n.of(context).save_format),
        commandBar: CommandBar(
          mainAxisAlignment: MainAxisAlignment.end,
          primaryItems: [
            CommandBarButton(
              icon: Icon(FluentIcons.refresh),
              onPressed: () async {
                _textEditingController.text = intialFormat;
                await userSetting.setFormat(intialFormat);
              },
            ),
            CommandBarButton(
              icon: Icon(FluentIcons.save),
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
              },
            ),
          ],
        ),
      ),
      content: Container(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: InfoLabel(
                  label: 'File Name Format',
                  child: TextBox(
                    controller: _textEditingController,
                    placeholder: 'Input File Name Format',
                  ),
                ),
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
                return ToggleSwitch(
                  content: Text(I18n.of(context).clear_old_format_file +
                      '\n' +
                      I18n.of(context).clear_old_format_file_message),
                  onChanged: (bool value) {
                    userSetting.setIsClearnOldFormatFile(value);
                  },
                  checked: userSetting.isClearOldFormatFile,
                );
              }),
              Table(
                children: [
                  TableRow(children: [
                    Text("Name"),
                    Text("Result"),
                  ]),
                  TableRow(children: [
                    Text('{illust_id}'),
                    Text(I18n.of(context).illust_id),
                  ]),
                  TableRow(children: [
                    Text('{title}'),
                    Text(I18n.of(context).title),
                  ]),
                  TableRow(children: [
                    Text('{user_id}'),
                    Text(I18n.of(context).painter_id),
                  ]),
                  TableRow(children: [
                    Text('{user_name}'),
                    Text(I18n.of(context).painter_name),
                  ]),
                  TableRow(children: [
                    Text('part'),
                    Text(I18n.of(context).which_part),
                  ]),
                ],
              )
            ],
          ),
        ),
      ),
      actions: [
        FilledButton(
          child: Text(I18n.of(context).ok),
          onPressed: Navigator.of(context).pop,
        ),
      ],
    );
  }
}
