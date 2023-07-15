import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/models/bookmark_detail.dart';
import 'package:pixez/page/picture/tag_for_illust_store.dart';

class TagForIllustPage extends StatefulWidget {
  final int id;

  const TagForIllustPage({Key? key, required this.id}) : super(key: key);

  @override
  _TagForIllustPageState createState() => _TagForIllustPageState();
}

class _TagForIllustPageState extends State<TagForIllustPage> {
  late TagForIllustStore _store;
  final TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    _store = TagForIllustStore(widget.id)..fetch();
    super.initState();
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: Row(
        children: [
          ToggleSwitch(
            onChanged: (bool value) {
              _store.setRestrict(value);
            },
            checked: _store.restrict == "public",
          ),
          Padding(
            padding: EdgeInsets.only(left: 16.0),
            child: Text((_store.restrict == "public"
                ? I18n.of(context).public
                : I18n.of(context).private)),
          ),
          Text(I18n.of(context).bookmark)
        ],
      ),
      content: Observer(builder: (_) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: <Widget>[
              TextBox(
                controller: textEditingController,
                suffix: IconButton(
                  icon: Icon(FluentIcons.add),
                  onPressed: () {
                    final value = textEditingController.value.text.trim();
                    if (value.isNotEmpty)
                      _store.insert(TagsR(isRegistered: true, name: value));
                    textEditingController.clear();
                  },
                ),
              ),
              _store.checkList.length == 0
                  ? Padding(
                      padding: EdgeInsets.only(top: 16.0),
                      child: Center(
                        child: ProgressRing(),
                      ),
                    )
                  : Expanded(
                      child: _store.errorMessage == null
                          ? ListView.builder(
                              padding: EdgeInsets.all(2.0).copyWith(
                                top: 8.0,
                              ),
                              itemCount: _store.checkList.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Padding(
                                  padding: EdgeInsets.only(bottom: 8.0),
                                  child: Checkbox(
                                    onChanged: (bool? value) {
                                      _store.check(index, value!);
                                    },
                                    content: Text(_store.tags[index].name),
                                    checked: _store.checkList[index],
                                  ),
                                );
                              },
                            )
                          : Container(
                              child: Container(
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Container(
                                      height: 50,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(':(',
                                          style: FluentTheme.of(context)
                                              .typography
                                              .title),
                                    ),
                                    HyperlinkButton(
                                        onPressed: () {
                                          _store.fetch();
                                        },
                                        child: Text(I18n.of(context).retry)),
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Text('${_store.errorMessage}'),
                                    )
                                  ],
                                ),
                              ),
                            ),
                    ),
            ],
          ),
        );
      }),
      actions: [
        FilledButton(
          child: Text(I18n.of(context).ok),
          onPressed: confirm,
        ),
        Button(
          child: Text(I18n.of(context).cancel),
          onPressed: Navigator.of(context).pop,
        )
      ],
    );
  }

  confirm() async {
    final tags = _store.tags;
    List<String>? tempTags = [];
    for (int i = 0; i < tags.length; i++) {
      if (tags[i].isRegistered) {
        tempTags.add(tags[i].name);
      }
    }
    if (tempTags.length == 0) tempTags = null;
    Navigator.of(context).pop({"restrict": _store.restrict, "tags": tempTags});
  }
}
