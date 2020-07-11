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

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/generated/l10n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/trend_tags.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/picture/illust_page.dart';
import 'package:pixez/page/preview/preview_page.dart';
import 'package:pixez/page/search/bloc/bloc.dart';
import 'package:pixez/page/search/result_page.dart';
import 'package:pixez/page/search/suggest/search_suggestion_page.dart';

class SearchPage extends StatefulWidget {

  const SearchPage({Key key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with SingleTickerProviderStateMixin {
  String editString = "";

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
    tagHistoryStore.fetch();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      if (accountStore.now != null)
        return MultiBlocProvider(
          providers: [
            BlocProvider<TrendTagsBloc>(
              create: (context) => TrendTagsBloc(apiClient)..add(FetchEvent()),
            )
          ],
          child: Column(children: <Widget>[
            AppBar(
              automaticallyImplyLeading: false,
              title: Text(
                I18n.of(context).Search,
                style: Theme.of(context).textTheme.headline6,
              ),
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute(
                            builder: (context) => SearchSuggestionPage()));
                  },
                )
              ],
            ),
            Expanded(child: _buildBlocBuilder())
          ]),
        );
      return Column(children: <Widget>[
        AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            I18n.of(context).Search,
            style: Theme.of(context).textTheme.headline6,
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {},
            )
          ],
        ),
        Expanded(child: LoginInFirst())
      ]);
    });
  }

  Widget _buildBlocBuilder() {
    return BlocBuilder<TrendTagsBloc, TrendTagsState>(
        builder: (context, state) {
      return _buildListView(state);
    });
  }

  TabController _tabController;

  ListView _buildListView(TrendTagsState state) {
    return ListView.builder(
      itemCount: 4,
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(I18n.of(context).History),
          );
        }
        if (index == 2) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(I18n.of(context).Recommand_Tag),
          );
        }
        if (index == 1) {
          return Observer(
            builder: (BuildContext context) {
              if (tagHistoryStore.tags.isNotEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Wrap(
                    children: tagHistoryStore.tags
                        .map((f) => ActionChip(
                              label: Text(f.name),
                              onPressed: () {
                                Navigator.of(context, rootNavigator: true)
                                    .push(MaterialPageRoute(
                                        builder: (context) => ResultPage(
                                              word: f.name,
                                              translatedName:
                                                  f.translatedName ?? '',
                                            )));
                              },
                            ))
                        .toList()
                          ..add(ActionChip(
                              label: Text(I18n.of(context).Clear),
                              onPressed: () {
                                tagHistoryStore.deleteAll();
                              })),
                    runSpacing: 0.0,
                    spacing: 3.0,
                  ),
                );
              }
              return Container();
            },
          );
        } else {
          if (state is TrendTagDataState)
            return _buildGrid(context, state.trendingTag.trend_tags);
          else
            return Container();
        }
      },
    );
  }

  Widget _buildGrid(BuildContext context, List<Trend_tags> tags) =>
      GridView.count(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        crossAxisCount: 3,
        children: List.generate(tags.length, (index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context, rootNavigator: true)
                    .push(MaterialPageRoute(builder: (_) {
                  return ResultPage(
                    word: tags[index].tag,
                  );
                }));
              },
              onLongPress: () {
                Navigator.of(context, rootNavigator: true)
                    .push(MaterialPageRoute(builder: (_) {
                  return IllustPage(id:tags[index].illust.id);
                }));
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3.0),
                child: Stack(
                  children: <Widget>[
                    CachedNetworkImage(
                      imageUrl: tags[index].illust.imageUrls.squareMedium,
                      httpHeaders: {
                        "referer": "https://app-api.pixiv.net/",
                        "User-Agent": "PixivIOSApp/5.8.0"
                      },
                      fit: BoxFit.fitWidth,
                    ),
                    Align(
                      child: Text(tags[index].tag),
                      alignment: Alignment.bottomCenter,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      );
}
