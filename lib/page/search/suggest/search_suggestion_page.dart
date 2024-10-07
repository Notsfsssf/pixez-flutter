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
import 'package:pixez/er/leader.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/page/picture/illust_lighting_page.dart';
// import 'package:pixez/page/saucenao/sauce_store.dart';
import 'package:pixez/page/search/result_page.dart';
import 'package:pixez/page/search/suggest/suggestion_store.dart';
import 'package:pixez/page/soup/soup_page.dart';
import 'package:pixez/page/user/users_page.dart';

class SearchSuggestionPage extends StatefulWidget {
  final String? preword;

  const SearchSuggestionPage({Key? key, this.preword}) : super(key: key);

  @override
  _SearchSuggestionPageState createState() => _SearchSuggestionPageState();
}

class _SearchSuggestionPageState extends State<SearchSuggestionPage> {
  late TextEditingController _filter;
  late SuggestionStore _suggestionStore;
  // late SauceStore _sauceStore;
  FocusNode focusNode = FocusNode();
  final tagGroup = [];
  bool idV = false;

  @override
  void initState() {
    idV = widget.preword != null && int.tryParse(widget.preword!) != null;
    _suggestionStore = SuggestionStore();
    // _sauceStore = SauceStore();
    // _sauceStore.observableStream.listen((event) {
    //   if (event != null && _sauceStore.results.isNotEmpty) {
    //     Navigator.of(context).push(MaterialPageRoute(
    //         builder: (context) => PageView(
    //               children: _sauceStore.results
    //                   .map((element) => IllustLightingPage(id: element))
    //                   .toList(),
    //             )));
    //   } else {
    //     BotToast.showText(text: "0 result");
    //   }
    // });
    var query = widget.preword ?? '';
    _filter = TextEditingController(text: query);
    var tags = query
        .split(" ")
        .map((e) => e.trim())
        .takeWhile((value) => value.isNotEmpty);
    if (tags.length > 1) tagGroup.addAll(tags);
    super.initState();
  }

  @override
  void dispose() {
    _filter.dispose();
    // _sauceStore.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      return Scaffold(
        appBar: _buildAppBar(context),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            // _sauceStore.findImage(context: context);
          },
          child: Icon(Icons.add_photo_alternate),
        ),
        body: Container(
            child: Column(
          children: [
            Container(
              height: 1,
              color: Theme.of(context).dividerColor,
            ),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Wrap(
                        spacing: 10,
                        children: [
                          for (String i in tagGroup)
                            ActionChip(
                                label: Text(i),
                                onPressed: () {
                                  final start = _filter.text.indexOf(i);
                                  if (start != -1)
                                    _filter.selection =
                                        TextSelection.fromPosition(TextPosition(
                                            offset: start + i.length));
                                })
                        ],
                      ),
                    ),
                  ),
                  SliverVisibility(
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        if (index == 0)
                          return ListTile(
                            title: Text(_filter.text),
                            subtitle: Text(I18n.of(context).illust_id),
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => IllustLightingPage(
                                        id: int.tryParse(_filter.text)!,
                                      )));
                            },
                          );
                        if (index == 1)
                          return ListTile(
                            title: Text(_filter.text),
                            subtitle: Text(I18n.of(context).painter_id),
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => UsersPage(
                                        id: int.tryParse(_filter.text)!,
                                      )));
                            },
                          );
                        if (index == 2 && _filter.text.length < 5)
                          return ListTile(
                            title: Text(_filter.text),
                            subtitle: Text("Pixivision Id"),
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => SoupPage(
                                        url:
                                            "https://www.pixivision.net/zh/a/${_filter.text.trim()}",
                                        spotlight: null,
                                      )));
                            },
                          );
                        return ListTile();
                      }, childCount: 3),
                    ),
                    visible: idV,
                  ),
                  if (_suggestionStore.autoWords != null &&
                      _suggestionStore.autoWords!.tags.isNotEmpty)
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final tags = _suggestionStore.autoWords!.tags;
                        return ListTile(
                          onTap: () {
                            if (tagGroup.length > 1) {
                              tagGroup.last = tags[index].name;
                              var text = tagGroup.join(" ");
                              _filter.text = text;
                              _filter.selection = TextSelection.fromPosition(
                                  TextPosition(offset: text.length));
                              setState(() {});
                            } else {
                              FocusScope.of(context).unfocus();
                              Navigator.of(context, rootNavigator: true)
                                  .push(MaterialPageRoute(builder: (context) {
                                return ResultPage(
                                  word: tags[index].name,
                                  translatedName:
                                      tags[index].translated_name ?? "",
                                );
                              }));
                            }
                          },
                          title: Text(tags[index].name),
                          subtitle: Text(tags[index].translated_name ?? ""),
                        );
                      }, childCount: _suggestionStore.autoWords!.tags.length),
                    ),
                ],
              ),
            ),
          ],
        )),
      );
    });
  }

  AppBar _buildAppBar(context) {
    return AppBar(
      title: _textField(context, TextInputType.text, focusNode),
      iconTheme:
          IconThemeData(color: Theme.of(context).textTheme.bodyLarge!.color),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.close,
              color: Theme.of(context).textTheme.bodyLarge!.color),
          onPressed: () {
            _filter.clear();
          },
        )
      ],
    );
  }

  TextField _textField(
      BuildContext context, TextInputType inputType, FocusNode node) {
    return TextField(
        controller: _filter,
        focusNode: node,
        keyboardType: inputType,
        autofocus: true,
        cursorColor: Theme.of(context).iconTheme.color,
        style: Theme.of(context)
            .textTheme
            .titleMedium!
            .copyWith(color: Theme.of(context).iconTheme.color),
        onTap: () {
          FocusScope.of(context).requestFocus(node);
        },
        onChanged: (query) {
          tagGroup.clear();
          var tags = query
              .split(" ")
              .map((e) => e.trim())
              .takeWhile((value) => value.isNotEmpty);
          if (tags.length > 1) tagGroup.addAll(tags);
          setState(() {});
          bool isNum = int.tryParse(query) != null;
          setState(() {
            idV = isNum;
          });
          if (query.startsWith('https://')) {
            Leader.pushWithUri(context, Uri.parse(query));
            _filter.clear();
            return;
          }
          var word = query.trim();
          if (word.isEmpty) return;
          if (isNum && word.length > 5) return; //超过五个数字应该就不需要给建议了吧
          word = tags.last;
          if (word.isEmpty) return;
          _suggestionStore.fetch(word);
        },
        onSubmitted: (s) {
          var word = s.trim();
          if (word.isEmpty) return;
          Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
              builder: (context) => ResultPage(
                    word: word,
                  )));
        },
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: I18n.of(context).search_word_or_paste_link,
        ));
  }
}
