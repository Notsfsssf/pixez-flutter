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

import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/tags.dart';
import 'package:pixez/page/picture/illust_lighting_page.dart';
import 'package:pixez/page/preview/preview_page.dart';
import 'package:pixez/page/saucenao/saucenao_page.dart';
import 'package:pixez/page/search/result_page.dart';
import 'package:pixez/page/search/suggest/search_suggestion_page.dart';
import 'package:pixez/page/search/trend_tags_store.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with TickerProviderStateMixin {
  String editString = "";
  late TrendTagsStore _trendTagsStore;
  late AnimationController _animationController;
  late Animation<double> animation;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _animationController.forward();
  }

  @override
  void initState() {
    _animationController = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    animation = Tween(begin: 0.0, end: 0.25).animate(_animationController);

    _trendTagsStore = TrendTagsStore();
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
    tagHistoryStore.fetch();
    _trendTagsStore.fetch();
  }

  bool _isExpanded = false;

  @override
  void dispose() {
    _animationController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildFirstRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            child: Padding(
              child: Text(
                I18n.of(context).search,
              ),
              padding: EdgeInsets.only(left: 16.0, bottom: 10.0),
            ),
          ),
        ],
      ),
    );
  }

  bool _tagExpand = false;

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      if (accountStore.now != null)
        return NestedScrollView(
          body: RefreshIndicator(
            onRefresh: () {
              return _trendTagsStore.fetch();
            },
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _buildFirstRow(context),
                ),
                SliverToBoxAdapter(
                  child: Observer(builder: (context) {
                    if (tagHistoryStore.tags
                        .where((element) =>
                            element.type == null || element.type == 0)
                        .isNotEmpty)
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              I18n.of(context).history,
                              style: TextStyle(
                                  fontSize: 16.0,
                                  color: Theme.of(context)
                                      .textTheme
                                      .headline5!
                                      .color),
                            ),
                          ],
                        ),
                      );
                    else
                      return Container();
                  }),
                ),
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  sliver: SliverToBoxAdapter(
                    child: Observer(
                      builder: (BuildContext context) {
                        if (tagHistoryStore.tags.isNotEmpty) {
                          final targetTags = tagHistoryStore.tags
                              .where((element) =>
                                  element.type == null || element.type == 0)
                              .toList();
                          if (targetTags.length > 20) {
                            final resultTags = targetTags.sublist(0, 12);
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5.0),
                              child: Wrap(
                                children: [
                                  for (var f
                                      in _tagExpand ? targetTags : resultTags)
                                    buildActionChip(f, context),
                                  ActionChip(
                                      label: AnimatedSwitcher(
                                        duration: Duration(milliseconds: 300),
                                        transitionBuilder: (child, anim) {
                                          return ScaleTransition(
                                              child: child, scale: anim);
                                        },
                                        child: Icon(!_tagExpand
                                            ? Icons.expand_more
                                            : Icons.expand_less),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _tagExpand = !_tagExpand;
                                        });
                                      })
                                ],
                                runSpacing: 0.0,
                                spacing: 5.0,
                              ),
                            );
                          }
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 5.0),
                            child: Wrap(
                              children: [
                                for (var f in targetTags)
                                  buildActionChip(f, context),
                              ],
                              runSpacing: 0.0,
                              spacing: 3.0,
                            ),
                          );
                        }
                        return Container();
                      },
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Observer(builder: (context) {
                    if (tagHistoryStore.tags
                        .where((element) =>
                            element.type == null || element.type == 0)
                        .isNotEmpty)
                      return InkWell(
                        onTap: () {
                          tagHistoryStore.deleteAll();
                        },
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.delete_outline,
                                  size: 18.0,
                                  color: Theme.of(context)
                                      .textTheme
                                      .caption!
                                      .color,
                                ),
                                Text(
                                  I18n.of(context).clear_search_tag_history,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText2!
                                      .copyWith(
                                          color: Theme.of(context)
                                              .textTheme
                                              .caption!
                                              .color),
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    return Container();
                  }),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      I18n.of(context).recommand_tag,
                      style: TextStyle(
                          fontSize: 16.0,
                          color: Theme.of(context).textTheme.headline6!.color),
                    ),
                  ),
                ),
                if (_trendTagsStore.trendTags.isNotEmpty)
                  SliverPadding(
                    padding: EdgeInsets.all(8.0),
                    sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final tags = _trendTagsStore.trendTags;
                          return GestureDetector(
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
                                return IllustLightingPage(
                                    id: tags[index].illust.id);
                              }));
                            },
                            child: Card(
                              clipBehavior: Clip.antiAlias,
                              shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8.0))),
                              child: Stack(
                                children: <Widget>[
                                  PixivImage(
                                    tags[index].illust.imageUrls.squareMedium,
                                    fit: BoxFit.cover,
                                  ),
                                  Opacity(
                                    opacity: 0.4,
                                    child: Container(
                                      decoration:
                                          BoxDecoration(color: Colors.black),
                                    ),
                                  ),
                                  Align(
                                    child: Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Text(
                                            tags[index].tag,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                    alignment: Alignment.bottomCenter,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }, childCount: _trendTagsStore.trendTags.length),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3)),
                  )
              ],
            ),
          ),
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              SliverAppBar(
                elevation: 0.0,
                titleSpacing: 0.0,
                automaticallyImplyLeading: false,
                leading: RotationTransition(
                  alignment: Alignment.center,
                  turns: animation,
                  child: IconButton(
                      icon: Icon(Icons.dashboard,
                          color: Theme.of(context).textTheme.bodyText1!.color),
                      onPressed: () async {
                        if (Platform.isAndroid)
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                            return SauceNaoPage();
                          }));
                      }),
                ),
                backgroundColor: Theme.of(context).canvasColor,
                actions: [
                  IconButton(
                    icon: Icon(Icons.search,
                        color: Theme.of(context).textTheme.bodyText1!.color),
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => SearchSuggestionPage()));
                    },
                  )
                ],
              ),
            ];
          },
        );
      return Column(children: <Widget>[
        AppBar(
          automaticallyImplyLeading: false,
          title: Text(I18n.of(context).search,
              style: TextStyle(color: Colors.white)),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.search,
              ),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(
                        builder: (context) => SearchSuggestionPage()));
              },
            )
          ],
        ),
      ]);
    });
  }

  Widget buildActionChip(TagsPersist f, BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('${I18n.of(context).delete}?'),
                actions: [
                  TextButton(
                      onPressed: () {
                        tagHistoryStore.delete(f.id!);
                        Navigator.of(context).pop();
                      },
                      child: Text(I18n.of(context).ok)),
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(I18n.of(context).cancel)),
                ],
              );
            });
      },
      child: ActionChip(
        padding: EdgeInsets.all(0.0),
        label: Text(
          f.name,
          style: TextStyle(fontSize: 12.0),
        ),
        onPressed: () {
          Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
              builder: (context) => ResultPage(
                    word: f.name,
                    translatedName: f.translatedName,
                  )));
        },
      ),
    );
  }

  late TabController _tabController;
}
