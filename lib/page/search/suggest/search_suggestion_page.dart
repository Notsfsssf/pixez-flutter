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
import 'package:pixez/page/picture/illust_lighting_page.dart';
import 'package:pixez/page/saucenao/sauce_store.dart';
import 'package:pixez/page/search/result_page.dart';
import 'package:pixez/page/search/suggest/suggestion_store.dart';
import 'package:pixez/page/user/users_page.dart';

class SearchSuggestionPage extends StatefulWidget {
  final String preword;

  const SearchSuggestionPage({Key key, this.preword}) : super(key: key);

  @override
  _SearchSuggestionPageState createState() => _SearchSuggestionPageState();
}

class _SearchSuggestionPageState extends State<SearchSuggestionPage> {
  TextEditingController _filter;
  SuggestionStore _suggestionStore;
  SauceStore _sauceStore;

  @override
  void initState() {
    _suggestionStore = SuggestionStore();
    _sauceStore = SauceStore();
    _sauceStore.observableStream.listen((event) {
      if (event != null && _sauceStore.results.isNotEmpty) {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => PageView(
                  children: _sauceStore.results
                      .map((element) => IllustLightingPage(id: element))
                      .toList(),
                )));
      } else {
        BotToast.showText(text: "0 result");
      }
    });
    _filter = TextEditingController(text: widget.preword ?? '');
    super.initState();
  }

  @override
  void dispose() {
    _filter?.dispose();
    _sauceStore?.dispose();
    super.dispose();
  }

  bool idV = false;

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      return Scaffold(
        appBar: _buildAppBar(context),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _sauceStore.findImage();
          },
          child: Icon(Icons.add_photo_alternate),
        ),
        body: Container(
            child: CustomScrollView(
          slivers: [
            SliverVisibility(
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  if (index == 0)
                    return ListTile(
                      title: Text(_filter.text ?? ''),
                      subtitle: Text(I18n.of(context).illust_id),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => IllustLightingPage(
                                  id: int.tryParse(_filter.text),
                                )));
                      },
                    );
                  return ListTile(
                    title: Text(_filter.text ?? ''),
                    subtitle: Text(I18n.of(context).painter_id),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => UsersPage(
                                id: int.tryParse(_filter.text),
                              )));
                    },
                  );
                }, childCount: 2),
              ),
              visible: idV,
            ),
            if (_suggestionStore.autoWords != null &&
                _suggestionStore.autoWords.tags.isNotEmpty)
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final tags = _suggestionStore.autoWords.tags;
                  return ListTile(
                    onTap: () {
                      FocusScope.of(context).unfocus();
                      Navigator.of(context, rootNavigator: true)
                          .push(MaterialPageRoute(builder: (context) {
                        return ResultPage(
                          word: tags[index].name,
                          translatedName: tags[index].translated_name ?? '',
                        );
                      }));
                    },
                    title: Text(tags[index].name),
                    subtitle: Text(tags[index].translated_name ?? ""),
                  );
                }, childCount: _suggestionStore.autoWords.tags.length),
              ),
          ],
        )),
      );
    });
  }

  FocusNode focusNode = FocusNode();

  AppBar _buildAppBar(context) {
    return AppBar(
      title: _textField(context, TextInputType.text, focusNode),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.close),
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
        onTap: () {
          FocusScope.of(context).requestFocus(node);
        },
        onChanged: (query) {
          bool isNum = int.tryParse(query) != null;
          setState(() {
            idV = isNum;
          });
          if (query.startsWith('https://')) {
            Uri uri = Uri.parse(query);
            if (!uri.host.contains('pixiv')) {
              return;
            }
            final segment = uri.pathSegments;
            if (segment.length == 1 && query.contains("/member.php?id=")) {
              final id = uri.queryParameters['id'];
              Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
                  builder: (BuildContext context) => UsersPage(
                        id: int.parse(id),
                      )));
              _filter.clear();
            }
            if (segment.length == 2) {
              if (segment[0] == 'artworks') {
                Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(
                        builder: (BuildContext context) =>
                            IllustLightingPage(id: int.parse(segment[1]))));
                _filter.clear();
              }
              if (segment[0] == 'users') {
                Navigator.of(context, rootNavigator: true)
                    .push(MaterialPageRoute(builder: (BuildContext context) {
                  return UsersPage(
                    id: int.parse(segment[1]),
                  );
                }));
                _filter.clear();
              }
            }
          }
          var word = query.trim();
          if (word.isEmpty) return;
          if (isNum && word.length > 5) return; //超过五个数字应该就不需要给建议了吧
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
          hintText: I18n.of(context).search_word_or_paste_link,
        ));
  }
}

class Suggestions extends StatefulWidget {
  final SuggestionStore suggestionStore;

  const Suggestions({Key key, this.suggestionStore}) : super(key: key);

  @override
  _SuggestionsState createState() => _SuggestionsState();
}

class _SuggestionsState extends State<Suggestions> {
  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        if (widget.suggestionStore.autoWords != null) {
          final tags = widget.suggestionStore.autoWords.tags;
          return tags.isNotEmpty
              ? ListView.separated(
                  itemBuilder: (context, index) {
                    return ListTile(
                      onTap: () {
                        FocusScope.of(context).unfocus();
                        Navigator.of(context, rootNavigator: true)
                            .push(MaterialPageRoute(builder: (context) {
                          return ResultPage(
                            word: tags[index].name,
                            translatedName: tags[index].translated_name ?? '',
                          );
                        }));
                      },
                      title: Text(tags[index].name),
                      subtitle: Text(tags[index].translated_name ?? ""),
                    );
                  },
                  itemCount: tags.length,
                  separatorBuilder: (BuildContext context, int index) {
                    return Divider();
                  },
                )
              : Container();
        }
        return Container();
      },
    );
  }
}
