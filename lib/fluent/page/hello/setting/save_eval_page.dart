import 'dart:convert';

import 'package:fluent_ui/fluent_ui.dart';
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
        squareMedium:
            "https://i.pximg.net/c/540x540_70/img-master/img/2020/12/31/00/00/00/84800000_p0_master1200.jpg",
        medium:
            "https://i.pximg.net/c/540x540_70/img-master/img/2020/12/31/00/00/00/84800000_p0_master1200.jpg",
        large:
            "https://i.pximg.net/c/540x540_70/img-master/img/2020/12/31/00/00/00/84800000_p0_master1200.jpg",
      ),
      totalComments: 1,
      caption: "caption",
      restrict: 0,
      user: User(
        id: 100000,
        name: "name",
        account: "account",
        profileImageUrls: ProfileImageUrls(
          medium:
              "https://i.pximg.net/c/540x540_70/img-master/img/2020/12/31/00/00/00/84800000_p0_master1200.jpg",
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
      totalBookmarks: 1000,
      isBookmarked: false,
      visible: true,
      isMuted: false,
      illustAIType: 1);

  @override
  void initState() {
    _textEditingController =
        TextEditingController(text: widget.eval ?? userSetting.nameEval);
    super.initState();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: PageHeader(
        title: Text("Eval"),
        commandBar: CommandBar(
          mainAxisAlignment: MainAxisAlignment.end,
          primaryItems: [
            CommandBarButton(
                onPressed: () async {
                  final text = _textEditingController.text.trim();
                  if (text.isEmpty) return;
                  final string =
                      await saveStore.testEvalName(text, _illusts, 1, "png");
                  await userSetting.setNameEval(string);
                  await userSetting.setFileNameEval(1);
                },
                icon: Icon(FluentIcons.check_mark))
          ],
        ),
      ),
      content: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text("File Name:"),
              subtitle: Text(_fileName ?? "undefined"),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: InfoLabel(
                label: 'Code',
                child: TextBox(
                  expands: true,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  controller: _textEditingController,
                  placeholder: 'Input Code here',
                ),
              ),
            ),
            HyperlinkButton(
              onPressed: () {
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
              child: Text("Read link from scheme"),
            ),
          ],
        ),
      ),
      actions: [
        Button(
          child: Text(I18n.of(context).cancel),
          onPressed: Navigator.of(context).pop,
        ),
        FilledButton(
          onPressed: () async {
            final text = _textEditingController.text.trim();
            if (text.isEmpty) return;
            run(text);
          },
          child: Text("Run"),
        ),
      ],
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
