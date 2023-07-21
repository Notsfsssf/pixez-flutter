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

import 'package:fluent_ui/fluent_ui.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';

class CopyTextPage extends StatefulWidget {
  const CopyTextPage({Key? key}) : super(key: key);

  @override
  State<CopyTextPage> createState() => _CopyTextPageState();
}

class _CopyTextPageState extends State<CopyTextPage> {
  late TextEditingController _textEditingController;
  final badText = ['/', '\\', ':', ' '];

  @override
  void initState() {
    _textEditingController =
        TextEditingController(text: userSetting.copyInfoText);
    super.initState();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  _buildActionNormalText(String text) => Button(
        child: Text("$text"),
        onPressed: () {
          if (_textEditingController.selection.end == -1) return;
          var insertText = text;
          if (text == "_") insertText = "_";
          final textSelection = _textEditingController.selection;
          _textEditingController.text = _textEditingController.text
              .replaceRange(textSelection.start, textSelection.end, insertText);
          _textEditingController.selection = textSelection.copyWith(
              baseOffset: textSelection.start + insertText.length,
              extentOffset: textSelection.start + insertText.length);
        },
      );

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

  String intialFormat =
      "title:{title}\npainter:{user_name}\nillust id:{illust_id}";

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: PageHeader(
        title: Text(I18n.of(context).share_info_format),
        commandBar: CommandBar(primaryItems: [
          CommandBarButton(
              icon: Icon(FluentIcons.refresh),
              onPressed: () async {
                _textEditingController.text = intialFormat;
                await userSetting.setCopyInfoText(intialFormat);
              }),
          CommandBarButton(
              icon: Icon(FluentIcons.save),
              onPressed: () async {
                final text = _textEditingController.text;
                await userSetting.setCopyInfoText(text);
                Navigator.of(context).pop();
              }),
        ]),
      ),
      content: Container(
        child: ListView(children: [
          Padding(
            padding: EdgeInsets.all(12),
            child: InfoLabel(
              label: I18n.of(context).share_info_format,
              child: TextBox(
                controller: _textEditingController,
                maxLines: null,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              spacing: 6.0,
              children: <Widget>[
                _buildActionText("title"),
                _buildActionText("illust_id"),
                _buildActionText("user_id"),
                _buildActionText("user_name"),
                _buildActionText("tags"),
                _buildActionNormalText(
                    "https://www.pixiv.net/artworks/{illust_id}"),
                _buildActionNormalText("https://www.pixiv.net/users/{user_id}"),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
