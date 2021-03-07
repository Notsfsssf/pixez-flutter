import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/generated/l10n.dart';
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
    textEditingController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      return Container(
        child: Column(
          children: <Widget>[
            AppBar(
              title: Text((_store.restrict == "public"
                      ? I18n.of(context).public
                      : I18n.of(context).private) +
                  I18n.of(context).bookmark),
              actions: [
                Switch(
                  onChanged: (bool value) {
                    _store.setRestrict(value);
                  },
                  value: _store.restrict == "public",
                ),
                IconButton(
                    icon: Icon(Icons.check),
                    onPressed: () {
                      confirm();
                    })
              ],
            ),
            Theme(
              data: Theme.of(context)
                  .copyWith(primaryColor: Theme.of(context).accentColor),
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: TextField(
                  controller: textEditingController,
                  decoration: InputDecoration(
                      suffixIcon: IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      final value = textEditingController.value.text.trim();
                      if (value.isNotEmpty)
                        _store.insert(TagsR(isRegistered: true, name: value));
                      textEditingController.clear();
                    },
                  )),
                ),
              ),
            ),
            Expanded(
              child: _store.errorMessage == null
                  ? ListView.builder(
                      padding: EdgeInsets.all(2.0),
                      itemCount: _store.checkList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(_store.tags[index].name),
                              ),
                            ),
                            Checkbox(
                              onChanged: (bool? value) {
                                _store.check(index, value!);
                              },
                              value: _store.checkList[index],
                            )
                          ],
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
                                  style: Theme.of(context).textTheme.headline4),
                            ),
                            FlatButton(
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
            )
          ],
        ),
      );
    });
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
