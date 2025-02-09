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
import 'dart:math';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart' hide SearchBar;
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/tags.dart';
import 'package:pixez/page/picture/illust_lighting_page.dart';
import 'package:pixez/page/saucenao/sauce_store.dart';
import 'package:pixez/page/search/result_page.dart';
import 'package:pixez/page/search/search_bar.dart';
import 'package:pixez/page/search/suggest/search_suggestion_page.dart';
import 'package:pixez/page/search/trend_tags_store.dart';
import 'package:pixez/page/webview/saucenao_webview_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  String editString = "";
  late TrendTagsStore _trendTagsStore;
  late AnimationController _animationController;
  late Animation<double> animation;
  late SauceStore _sauceStore;

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
        BotToast.showText(text: I18n.ofContext().no_result);
      }
    });
    super.initState();
    tagHistoryStore.fetch();
    _trendTagsStore.fetch();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _tabController.dispose();
    _sauceStore.dispose();
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
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30.0,
                    color: Theme.of(context).textTheme.titleLarge!.color),
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
    super.build(context);
    return LayoutBuilder(builder: (context, snapshot) {
      return Observer(builder: (_) {
        if (accountStore.now != null)
          return NestedScrollView(
            body: _buildContent(context, snapshot),
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return [
                SliverToBoxAdapter(
                  child: Container(height: MediaQuery.of(context).padding.top),
                ),
                SliverToBoxAdapter(
                  child: SearchBar(
                    onSaucenao: () {
                      if (userSetting.useSaunceNaoWebview) {
                        Leader.push(context, SauncenaoWebview());
                      } else {
                        _sauceStore.findImage(context: context);
                      }
                    },
                  ),
                )
              ];
            },
          );
        return Column(children: <Widget>[
          AppBar(
            automaticallyImplyLeading: false,
            title: Text(
              I18n.of(context).search,
              style: Theme.of(context).textTheme.titleLarge,
            ),
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
    });
  }

  Widget _buildContent(BuildContext context, BoxConstraints snapshot) {
    final rowCount = max(3, (snapshot.maxWidth / 200).floor());
    return RefreshIndicator(
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
                  .where((element) => element.type == null || element.type == 0)
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
                                .headlineSmall!
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
                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                        child: Wrap(
                          children: [
                            for (var f in _tagExpand ? targetTags : resultTags)
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
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Wrap(
                        children: [
                          for (var f in targetTags) buildActionChip(f, context),
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
                  .where((element) => element.type == null || element.type == 0)
                  .isNotEmpty)
                return InkWell(
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text(I18n.of(context).clean_history),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(I18n.of(context).cancel)),
                              TextButton(
                                  onPressed: () {
                                    tagHistoryStore.deleteAll();
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(I18n.of(context).ok))
                            ],
                          );
                        });
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
                            color: Theme.of(context).textTheme.bodySmall!.color,
                          ),
                          Text(
                            I18n.of(context).clear_search_tag_history,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
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
                    color: Theme.of(context).textTheme.titleLarge!.color),
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
                          return IllustLightingPage(id: tags[index].illust.id);
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
                                decoration: BoxDecoration(color: Colors.black),
                              ),
                            ),
                            Align(
                              child: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Text(
                                      "#${tags[index].tag}",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 12),
                                    ),
                                    if (tags[index].translatedName != null &&
                                        tags[index].translatedName!.isNotEmpty)
                                      Text(
                                        tags[index].translatedName!,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 10),
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
                      crossAxisCount: rowCount)),
            ),
          if (Platform.isAndroid)
            SliverToBoxAdapter(
              child: Container(
                height: (MediaQuery.of(context).size.width / 3) - 16,
              ),
            )
        ],
      ),
    );
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

  @override
  bool get wantKeepAlive => true;
}
