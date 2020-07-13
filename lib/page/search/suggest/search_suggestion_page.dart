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

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/generated/l10n.dart';
import 'package:pixez/page/picture/illust_page.dart';
import 'package:pixez/page/search/result_page.dart';
import 'package:pixez/page/search/suggest/suggestion_store.dart';
import 'package:pixez/page/user/users_page.dart';

class SearchSuggestionPage extends StatefulWidget {
  final String preword;

  const SearchSuggestionPage({Key key, this.preword}) : super(key: key);
  @override
  _SearchSuggestionPageState createState() => _SearchSuggestionPageState();
}

class _SearchSuggestionPageState extends State<SearchSuggestionPage>
    with SingleTickerProviderStateMixin {
  TextEditingController _filter;
  TabController _tabController;
  SuggestionStore _suggestionStore;
  @override
  void initState() {
    _suggestionStore = SuggestionStore();
    _filter = TextEditingController(text: widget.preword ?? '');
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _filter?.dispose();
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Container(
          child: Suggestions(
        suggestionStore: _suggestionStore,
      )),
    );
  }

  FocusNode focusNode = FocusNode();

  AppBar _buildAppBar(context) {
    return AppBar(
      title: TextField(
          controller: _filter,
          focusNode: focusNode,
          autofocus: true,
          onTap: () {
            FocusScope.of(context).requestFocus(focusNode);
          },
          onChanged: (query) {
            if (query.startsWith('https://')) {
              Uri uri = Uri.parse(query);
              if (!uri.host.contains('pixiv')) {
                return;
              }
              final segment = uri.pathSegments;
              if (segment.length == 1 && query.contains("/member.php?id=")) {
                final id = uri.queryParameters['id'];
                Navigator.of(context, rootNavigator: true)
                    .push(MaterialPageRoute(
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
                              IllustPage(id: int.parse(segment[1]))));
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
            _suggestionStore.fetch(word);
          },
          onSubmitted: (s) {
            var word = s.trim();
            if (word.isEmpty) return;
            switch (_tabController.index) {
              case 0:
                {
                  Navigator.of(context, rootNavigator: true)
                      .push(MaterialPageRoute(
                          builder: (context) => ResultPage(
                                word: word,
                              )));
                }
                break;
              case 1:
                {
                  var id = int.tryParse(word);
                  if (id != null) {
                    Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute(builder: (_) => IllustPage(id: id)));
                  } else {
                    _filter.clear();
                  }
                }
                break;
              case 2:
                {
                  var id = int.tryParse(word);
                  if (id != null) {
                    Navigator.of(context, rootNavigator: true)
                        .push(MaterialPageRoute(
                            builder: (_) => UsersPage(
                                  id: id,
                                )));
                  } else {
                    _filter.clear();
                  }
                }
                break;
            }
          },
          decoration: InputDecoration(
            hintText: I18n.of(context).Search_word_or_paste_link,
          )),
      bottom: TabBar(
        controller: _tabController,
        tabs: <Widget>[
          Tab(
            child: Text(I18n.of(context).Key_Word),
          ),
          Tab(
            child: Text(I18n.of(context).Illust_id),
          ),
          Tab(
            child: Text(I18n.of(context).Painter_id),
          ),
        ],
      ),
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
