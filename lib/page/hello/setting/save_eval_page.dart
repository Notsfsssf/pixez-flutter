import 'dart:convert';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/illust.dart';

class SaveEvalPage extends StatefulWidget {
  final String? eval;
  const SaveEvalPage({Key? key, this.eval}) : super(key: key);

  @override
  State<SaveEvalPage> createState() => _SaveEvalPageState();
}

class _SaveEvalPageState extends State<SaveEvalPage> {
  late TextEditingController _textEditingController;
  String? _fileName;
  Illusts _illusts = Illusts(
      id: 100000,
      title: "title",
      type: "illust",
      imageUrls: ImageUrls(
        squareMedium: "https://c/xxx.jpg",
        medium: "https://c/xxx.png",
        large: "https://c/xxx.jpeg",
      ),
      caption: "caption",
      restrict: 0,
      user: User(
        id: 100000,
        name: "name",
        account: "account",
        profileImageUrls: ProfileImageUrls(
          medium: "https://c/xxxxx.jpg",
        ),
        isFollowed: false,
      ),
      tags: [
        Tags(name: "tag1", translatedName: "tag1Tranlate"),
        Tags(name: "tag2", translatedName: "tag2Tranlate"),
      ],
      tools: ["SAI"],
      createDate: "2020-12-31T00:00:00+09:00",
      pageCount: 1,
      width: 500,
      height: 500,
      sanityLevel: 6,
      xRestrict: 0,
      metaPages: [],
      totalView: 100000,
      totalComments: 1,
      totalBookmarks: 1000,
      isBookmarked: false,
      visible: true,
      isMuted: false,
      illustAIType: 0);

  String _exampleJson = "";

  @override
  void initState() {
    _textEditingController = TextEditingController(
        text: widget.eval ?? userSetting.nameEval ?? default_func_str);
    super.initState();
    _exampleJson = JsonEncoder.withIndent('  ').convert(_illusts.toJson());
  }

  final default_func_str = '''
function eval(illust, index, mime) {
  return illust.id + "_p" + index + "." + mime;
}
''';

  @override
  void dispose() {
    _textEditingController.dispose();
    FocusManager.instance.primaryFocus?.unfocus();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Script"),
        actions: [
          IconButton(
              onPressed: () async {
                await userSetting.setFileNameEval(0);
                Navigator.of(context).pop();
              },
              icon: Icon(Icons.cancel)),
          IconButton(
              onPressed: () async {
                final text = _textEditingController.text.trim();
                if (text.isEmpty) return;
                final string =
                    await saveStore.testEvalName(text, _illusts, 1, "png");
                if (string.isEmpty) {
                  BotToast.showText(text: "func eval error");
                  return;
                }
                await userSetting.setNameEval(text);
                await userSetting.setFileNameEval(1);
                Navigator.of(context).pop();
              },
              icon: Icon(Icons.check))
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 12,
            ),
            ListTile(
              title: Text(I18n.of(context).script_page_hint),
            ),
            ListTile(
              title: Text("Example output file name:"),
              subtitle: Text(_fileName ?? "undefined"),
            ),
            Container(
              height: 200,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                    expands: true,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    controller: _textEditingController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Input Code here',
                      labelText: 'Code',
                    )),
              ),
            ),
            ListTile(
              leading: Icon(Icons.read_more),
              title: Text("Read script from scheme"),
              onTap: () {
                Clipboard.getData("text/plain").then((value) {
                  if (value == null || value.text == null) return;
                  if (!value.text!.startsWith("pixez")) return;
                  final link = Uri.tryParse(value.text!);
                  if (link == null) return;
                  final base64 = link.queryParameters["code"];
                  if (base64 == null) return;
                  final result = String.fromCharCodes(base64Decode(base64));
                  run(result);
                });
              },
            ),
            ListTile(
              leading: Icon(Icons.play_arrow),
              title: Text("Run and test"),
              onTap: () async {
                final text = _textEditingController.text.trim();
                if (text.isEmpty) return;
                run(text);
              },
            ),
            ListTile(
              title: Text("Example illust json:"),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(_exampleJson),
            )
          ],
        ),
      ),
    );
  }

  void run(String text) async {
    try {
      final string = await saveStore.testEvalName(text, _illusts, 1, "png");
      setState(() {
        _fileName = string;
      });
    } catch (e) {
      print(e);
    }
  }
}
