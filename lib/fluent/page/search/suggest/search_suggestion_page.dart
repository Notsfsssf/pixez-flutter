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
import 'package:pixez/er/leader.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/page/picture/illust_lighting_page.dart';
import 'package:pixez/page/saucenao/sauce_store.dart';
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
  late SauceStore _sauceStore;
  FocusNode focusNode = FocusNode();
  final tagGroup = [];
  bool idV = false;

  @override
  void initState() {
    _suggestionStore = SuggestionStore();
    _sauceStore = SauceStore();
    _sauceStore.observableStream.listen((event) {
      if (event != null && _sauceStore.results.isNotEmpty) {
        Leader.push(
          context,
          PageView(
            children: _sauceStore.results
                .map((element) => IllustLightingPage(id: element))
                .toList(),
          ),
          icon: const Icon(FluentIcons.picture_library),
          title: Text(I18n.of(context).search),
        );
      } else {
        BotToast.showText(text: I18n.ofContext().no_result);
      }
    });
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
    _sauceStore.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      return ScaffoldPage(
        header: _buildAppBar(context),
        content: Container(
          child: Column(
            children: [
              Divider(),
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
                              Button(
                                child: Text(i),
                                onPressed: () {
                                  final start = _filter.text.indexOf(i);
                                  if (start != -1)
                                    _filter.selection =
                                        TextSelection.fromPosition(
                                      TextPosition(
                                        offset: start + i.length,
                                      ),
                                    );
                                },
                              )
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
                              onPressed: () {
                                Leader.push(
                                  context,
                                  IllustLightingPage(
                                    id: int.tryParse(_filter.text)!,
                                  ),
                                  icon: const Icon(FluentIcons.picture),
                                  title: Text(_filter.text),
                                );
                              },
                            );
                          if (index == 1)
                            return ListTile(
                              title: Text(_filter.text),
                              subtitle: Text(I18n.of(context).painter_id),
                              onPressed: () {
                                Leader.push(
                                  context,
                                  UsersPage(
                                    id: int.tryParse(_filter.text)!,
                                  ),
                                  icon: const Icon(FluentIcons.picture),
                                  title: Text(_filter.text),
                                );
                              },
                            );
                          if (index == 2 && _filter.text.length < 5)
                            return ListTile(
                              title: Text(_filter.text),
                              subtitle: Text("Pixivision Id"),
                              onPressed: () {
                                Leader.push(
                                  context,
                                  SoupPage(
                                    url:
                                        "https://www.pixivision.net/zh/a/${_filter.text.trim()}",
                                    spotlight: null,
                                  ),
                                  icon: const Icon(FluentIcons.picture),
                                  title: Text(_filter.text),
                                );
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
                            onPressed: () {
                              if (tagGroup.length > 1) {
                                tagGroup.last = tags[index].name;
                                var text = tagGroup.join(" ");
                                _filter.text = text;
                                _filter.selection = TextSelection.fromPosition(
                                    TextPosition(offset: text.length));
                                setState(() {});
                              } else {
                                FocusScope.of(context).unfocus();
                                Leader.push(
                                  context,
                                  ResultPage(
                                    word: tags[index].name,
                                    translatedName:
                                        tags[index].translated_name ?? "",
                                  ),
                                  icon: Icon(FluentIcons.search),
                                  title: Text(I18n.of(context).search +
                                      " " +
                                      tags[index].name),
                                );
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
          ),
        ),
      );
    });
  }

  PageHeader _buildAppBar(context) {
    return PageHeader(
      title: _textField(context, TextInputType.text, focusNode),
      commandBar: CommandBar(
        primaryItems: [
          CommandBarButton(
            onPressed: () {
              _sauceStore.findImage();
            },
            icon: Icon(FluentIcons.add_field),
          ),
          CommandBarButton(
            icon: Icon(FluentIcons.chrome_close,
                color: FluentTheme.of(context).typography.body!.color),
            onPressed: () {
              _filter.clear();
            },
          )
        ],
      ),
    );
  }

  TextBox _textField(
      BuildContext context, TextInputType inputType, FocusNode node) {
    return TextBox(
      controller: _filter,
      focusNode: node,
      keyboardType: inputType,
      autofocus: true,
      cursorColor: FluentTheme.of(context).iconTheme.color,
      style: FluentTheme.of(context)
          .typography
          .subtitle!
          .copyWith(color: FluentTheme.of(context).iconTheme.color),
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
        Leader.push(
          context,
          ResultPage(
            word: word,
          ),
          icon: const Icon(FluentIcons.search),
          title: Text(I18n.of(context).search + " " + word),
        );
      },
      placeholder: I18n.of(context).search_word_or_paste_link,
    );
  }
}
