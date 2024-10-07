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

import 'package:bot_toast/bot_toast.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/component/ban_page.dart';
import 'package:pixez/component/common_back_area.dart';
import 'package:pixez/component/null_hero.dart';
import 'package:pixez/component/painter_avatar.dart';
import 'package:pixez/component/pixez_default_header.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/component/star_icon.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/er/lprinter.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/ban_illust_id.dart';
import 'package:pixez/models/ban_tag.dart';
import 'package:pixez/models/illust.dart';
import 'package:pixez/page/picture/illust_about_store.dart';
import 'package:pixez/page/picture/illust_detail_content.dart';
import 'package:pixez/page/picture/illust_row_page.dart';
import 'package:pixez/page/picture/illust_store.dart';
import 'package:pixez/page/picture/picture_list_page.dart';
import 'package:pixez/page/picture/tag_for_illust_page.dart';
import 'package:pixez/page/picture/ugoira_loader.dart';
import 'package:pixez/page/picture/user_follow_button.dart';
import 'package:pixez/page/report/report_items_page.dart';
import 'package:pixez/page/search/result_page.dart';
import 'package:pixez/page/user/user_store.dart';
import 'package:pixez/page/user/users_page.dart';
import 'package:pixez/page/zoom/photo_zoom_page.dart';
import 'package:pixez/supportor_plugin.dart';
import 'package:share_plus/share_plus.dart';

class IllustLightingPage extends StatefulWidget {
  final int id;
  final String? heroString;
  final IllustStore? store;
  final GestureDragEndCallback? onHorizontalDragEnd;

  const IllustLightingPage(
      {Key? key,
      required this.id,
      this.heroString,
      this.store,
      this.onHorizontalDragEnd})
      : super(key: key);

  @override
  State<IllustLightingPage> createState() => _IllustLightingPageState();
}

class _IllustLightingPageState extends State<IllustLightingPage> {
  @override
  Widget build(BuildContext context) {
    switch (userSetting.padMode) {
      case 0:
        MediaQueryData mediaQuery = MediaQuery.of(context);
        final ori = mediaQuery.size.width > mediaQuery.size.height;
        if (ori)
          return _buildRow();
        else
          return _buildVertical();
      case 1:
        return _buildVertical();
      case 2:
        return _buildRow();
      default:
        return Container();
    }
  }

  _buildVertical() {
    return IllustVerticalPage(
      id: widget.id,
      store: widget.store,
      heroString: widget.heroString,
      onHorizontalDragEnd: widget.onHorizontalDragEnd,
    );
  }

  _buildRow() {
    return IllustRowPage(
      id: widget.id,
      store: widget.store,
      heroString: widget.heroString,
      onHorizontalDragEnd: widget.onHorizontalDragEnd,
    );
  }
}

class IllustVerticalPage extends StatefulWidget {
  final int id;
  final String? heroString;
  final IllustStore? store;
  final GestureDragEndCallback? onHorizontalDragEnd;

  const IllustVerticalPage(
      {Key? key,
      required this.id,
      this.heroString,
      this.store,
      this.onHorizontalDragEnd})
      : super(key: key);

  @override
  _IllustVerticalPageState createState() => _IllustVerticalPageState();
}

class _IllustVerticalPageState extends State<IllustVerticalPage>
    with AutomaticKeepAliveClientMixin {
  UserStore? userStore;
  late IllustStore _illustStore;
  late IllustAboutStore _aboutStore;
  late ScrollController _scrollController;
  late EasyRefreshController _refreshController;
  bool tempView = false;

  @override
  void initState() {
    _focusNode = FocusNode();
    _refreshController = EasyRefreshController(
        controlFinishLoad: true, controlFinishRefresh: true);
    _scrollController = ScrollController();
    _illustStore = widget.store ?? IllustStore(widget.id, null);
    _illustStore.fetch();
    _aboutStore = IllustAboutStore(widget.id, _refreshController);
    super.initState();
    supportTranslateCheck();
  }

  @override
  void didUpdateWidget(covariant IllustVerticalPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.store != widget.store) {
      _illustStore = widget.store ?? IllustStore(widget.id, null);
      _illustStore.fetch();
      _aboutStore = IllustAboutStore(widget.id, _refreshController);
      LPrinter.d("state change");
    }
  }

  void _loadAbout() {
    if (mounted &&
        _scrollController.hasClients &&
        _aboutStore.illusts.isEmpty &&
        !_aboutStore.fetching) {
      _aboutStore.next();
    }
  }

  @override
  void dispose() {
    _illustStore.dispose();
    _scrollController.dispose();
    _refreshController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Widget _buildAppbar() {
    return Column(
      children: [
        Container(
          height: MediaQuery.of(context).padding.top,
        ),
        Container(
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CommonBackArea(),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                      icon: Icon(Icons.expand_less),
                      onPressed: () {
                        double p = _scrollController.position.maxScrollExtent -
                            (_aboutStore.illusts.length / 3.0) *
                                (MediaQuery.of(context).size.width / 3.0);
                        if (p < 0) p = 0;
                        _scrollController.position.jumpTo(p);
                      }),
                  IconButton(
                      icon: Icon(Icons.more_vert),
                      onPressed: () {
                        buildShowModalBottomSheet(
                            context, _illustStore.illusts!);
                      })
                ],
              )
            ],
          ),
        ),
      ],
    );
  }

  late FocusNode _focusNode;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _buildBody(context);
  }

  Widget _buildBody(BuildContext context) {
    return Container(
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          extendBody: true,
          extendBodyBehindAppBar: true,
          floatingActionButton: GestureDetector(
            onLongPress: () {
              _showBookMarkTag();
            },
            onHorizontalDragEnd: (DragEndDetails detail) {
              if (widget.onHorizontalDragEnd != null) {
                widget.onHorizontalDragEnd!(detail);
              }
            },
            child: Observer(builder: (context) {
              return Visibility(
                visible: _illustStore.errorMessage == null,
                child: FloatingActionButton(
                  heroTag: widget.id,
                  onPressed: () async {
                    if (userSetting.saveAfterStar &&
                        (_illustStore.state == 0)) {
                      saveStore.saveImage(_illustStore.illusts!);
                    }
                    _illustStore.star(
                        restrict: userSetting.defaultPrivateLike
                            ? "private"
                            : "public");
                    if (userSetting.followAfterStar) {
                      bool success = await _illustStore.followAfterStar();
                      if (success) {
                        userStore?.isFollow = true;
                        BotToast.showText(
                            text:
                                "${_illustStore.illusts!.user.name} ${I18n.of(context).followed}");
                      }
                    }
                  },
                  child: Observer(builder: (_) {
                    return StarIcon(
                      state: _illustStore.state,
                    );
                  }),
                ),
              );
            }),
          ),
          body: Observer(builder: (_) {
            if (!tempView)
              for (var i in muteStore.banillusts) {
                if (i.illustId == widget.id.toString()) {
                  return BanPage(
                    name: "${I18n.of(context).illust}\n${i.name}\n",
                    onPressed: () {
                      setState(() {
                        tempView = true;
                      });
                    },
                  );
                }
              }
            if (!tempView && _illustStore.illusts != null) {
              for (var j in muteStore.banUserIds) {
                if (j.userId == _illustStore.illusts!.user.id.toString()) {
                  return BanPage(
                    name: "${I18n.of(context).painter}\n${j.name}\n",
                    onPressed: () {
                      setState(() {
                        tempView = true;
                      });
                    },
                  );
                }
              }
              for (var t in muteStore.banTags) {
                for (var t1 in _illustStore.illusts!.tags) {
                  if (t.name == t1.name)
                    return BanPage(
                      name: "${I18n.of(context).tag}\n${t.name}\n",
                      onPressed: () {
                        setState(() {
                          tempView = true;
                        });
                      },
                    );
                }
              }
            }
            return Container(
              child: Stack(
                children: [
                  _buildContent(context, _illustStore.illusts),
                  _buildAppbar()
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  bool supportTranslate = false;

  Future<void> supportTranslateCheck() async {
    if (!Platform.isAndroid) return;
    bool results = await SupportorPlugin.processText();
    if (mounted) {
      setState(() {
        supportTranslate = results;
      });
    }
  }

  Widget colorText(String text, BuildContext context) {
    return SelectionArea(
      child: Text(
        text,
        style: TextStyle(
            color: Theme.of(context).colorScheme.secondary, fontSize: 12),
      ),
    );
  }

  ScrollController scrollController = ScrollController();

  Widget _buildContent(BuildContext context, Illusts? data) {
    if (_illustStore.errorMessage != null) return _buildErrorContent(context);
    if (data == null)
      return Container(
        child: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
      );
    if (userStore == null) userStore = UserStore(data.user.id, null, data.user);
    return EasyRefresh(
      controller: _refreshController,
      header: PixezDefault.header(context),
      footer: PixezDefault.footer(context),
      onLoad: () {
        _aboutStore.next();
      },
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          if (userSetting.isBangs || ((data.width / data.height) > 5))
            SliverToBoxAdapter(
                child: Container(height: MediaQuery.of(context).padding.top)),
          ..._buildPhotoList(data),
          SliverToBoxAdapter(
            child: IllustDetailContent(
              illusts: data,
              userStore: userStore,
              illustStore: _illustStore,
              loadAbout: () {
                _loadAbout();
              },
            ),
          ),
          SliverGrid(
              delegate:
                  SliverChildBuilderDelegate((BuildContext context, int index) {
                var list = _aboutStore.illusts
                    .map((element) => IllustStore(element.id, element))
                    .toList();
                return InkWell(
                  onTap: () {
                    Leader.push(
                        context,
                        PictureListPage(
                          iStores: list,
                          lightingStore: null,
                          store: list[index],
                        ));
                  },
                  onLongPress: () async {
                    if (userSetting.longPressSaveConfirm) {
                      final result = await showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text(I18n.of(context).save),
                              content: Text(list[index].illusts?.title ?? ""),
                              actions: <Widget>[
                                TextButton(
                                  child: Text(I18n.of(context).cancel),
                                  onPressed: () {
                                    Navigator.of(context).pop(false);
                                  },
                                ),
                                TextButton(
                                  child: Text(I18n.of(context).ok),
                                  onPressed: () {
                                    Navigator.of(context).pop(true);
                                  },
                                ),
                              ],
                            );
                          });
                      if (!result) {
                        return;
                      }
                    }
                    if (userSetting.starAfterSave &&
                        (_illustStore.state == 0)) {
                      _illustStore.star(
                          restrict: userSetting.defaultPrivateLike
                              ? "private"
                              : "public");
                    }
                    saveStore.saveImage(_aboutStore.illusts[index]);
                  },
                  child: PixivImage(
                    _aboutStore.illusts[index].imageUrls.squareMedium,
                    enableMemoryCache: false,
                  ),
                );
              }, childCount: _aboutStore.illusts.length),
              gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3))
        ],
      ),
    );
  }

  List<Widget> _buildPhotoList(Illusts data) {
    final height = ((data.height.toDouble() / data.width) *
        MediaQuery.of(context).size.width);
    return [
      if (data.type == "ugoira")
        SliverToBoxAdapter(
          child: NullHero(
            tag: widget.heroString,
            child: UgoiraLoader(
              id: widget.id,
              illusts: data,
            ),
          ),
        ),
      if (data.type != "ugoira")
        data.pageCount == 1
            ? SliverList(
                delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                String url = userSetting.pictureQuality == 1
                    ? data.imageUrls.large
                    : data.imageUrls.medium;
                if (data.type == "manga") {
                  if (userSetting.mangaQuality == 0)
                    url = data.imageUrls.medium;
                  else if (userSetting.mangaQuality == 1)
                    url = data.imageUrls.large;
                  else
                    url = data.metaSinglePage!.originalImageUrl!;
                }
                Widget placeWidget = Container(height: height);
                return InkWell(
                  onLongPress: () {
                    _pressSave(data, 0);
                  },
                  onTap: () {
                    Leader.push(
                        context,
                        PhotoZoomPage(
                          index: 0,
                          illusts: data,
                          illustStore: _illustStore,
                        ));
                  },
                  child: NullHero(
                    tag: widget.heroString,
                    child: PixivImage(
                      url,
                      fade: false,
                      width: MediaQuery.of(context).size.width,
                      placeWidget: (url != data.imageUrls.medium)
                          ? PixivImage(
                              data.imageUrls.medium,
                              width: MediaQuery.of(context).size.width,
                              placeWidget: placeWidget,
                              fade: false,
                            )
                          : placeWidget,
                    ),
                  ),
                );
              }, childCount: 1))
            : SliverList(
                delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                return InkWell(
                    onLongPress: () {
                      _pressSave(data, index);
                    },
                    onTap: () {
                      Leader.push(
                          context,
                          PhotoZoomPage(
                            index: index,
                            illusts: data,
                            illustStore: _illustStore,
                          ));
                    },
                    child: _buildIllustsItem(index, data, height));
              }, childCount: data.metaPages.length)),
    ];
  }

  Center _buildErrorContent(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child:
                Text(':(', style: Theme.of(context).textTheme.headlineMedium),
          ),
          Text(
            '${_illustStore.errorMessage}',
            maxLines: 5,
          ),
          ElevatedButton(
            onPressed: () {
              _illustStore.fetch();
            },
            child: Text(I18n.of(context).refresh),
          )
        ],
      ),
    );
  }

  Widget _buildIllustsItem(int index, Illusts illust, double height) {
    if (illust.type == "manga") {
      String url;
      if (userSetting.mangaQuality == 0)
        url = illust.metaPages[index].imageUrls!.medium;
      else if (userSetting.mangaQuality == 1)
        url = illust.metaPages[index].imageUrls!.large;
      else
        url = illust.metaPages[index].imageUrls!.original;
      if (index == 0)
        return NullHero(
          child: PixivImage(
            url,
            placeWidget: PixivImage(
              illust.metaPages[index].imageUrls!.medium,
              width: MediaQuery.of(context).size.width,
              fade: false,
            ),
            width: MediaQuery.of(context).size.width,
            fade: false,
          ),
          tag: widget.heroString,
        );
      return PixivImage(
        url,
        fade: false,
        width: MediaQuery.of(context).size.width,
        placeWidget: Container(
          height: height,
          child: Center(
            child: Text('$index',
                style: Theme.of(context).textTheme.headlineMedium),
          ),
        ),
      );
    }
    return index == 0
        ? (userSetting.pictureQuality == 1
            ? NullHero(
                child: PixivImage(
                  illust.metaPages[index].imageUrls!.large,
                  placeWidget: PixivImage(
                    illust.metaPages[index].imageUrls!.medium,
                    fade: false,
                  ),
                  fade: false,
                ),
                tag: widget.heroString,
              )
            : NullHero(
                child: PixivImage(
                  illust.metaPages[index].imageUrls!.medium,
                  fade: false,
                ),
                tag: widget.heroString,
              ))
        : PixivImage(
            userSetting.pictureQuality == 0
                ? illust.metaPages[index].imageUrls!.medium
                : illust.metaPages[index].imageUrls!.large,
            fade: false,
            placeWidget: Container(
              height: 150,
              child: Center(
                child: Text('$index',
                    style: Theme.of(context).textTheme.headlineMedium),
              ),
            ),
          );
  }

  Future _longPressTag(BuildContext context, Tags f) async {
    switch (await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: RichText(
              text: TextSpan(children: [
                TextSpan(
                    text: "${f.name}",
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Theme.of(context).colorScheme.primary)),
                if (f.translatedName != null)
                  TextSpan(
                      text: "\n${"${f.translatedName}"}",
                      style: Theme.of(context).textTheme.bodyLarge!)
              ]),
            ),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 0);
                },
                child: Text(I18n.of(context).ban),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 1);
                },
                child: Text(I18n.of(context).bookmark),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 2);
                },
                child: Text(I18n.of(context).copy),
              ),
            ],
          );
        })) {
      case 0:
        {
          muteStore.insertBanTag(BanTagPersist(
              name: f.name, translateName: f.translatedName ?? ""));
        }
        break;
      case 1:
        {
          bookTagStore.bookTag(f.name);
        }
        break;
      case 2:
        {
          await Clipboard.setData(ClipboardData(text: f.name));
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            duration: Duration(seconds: 1),
            content: Text(I18n.of(context).copied_to_clipboard),
          ));
        }
    }
  }

  Widget buildRow(BuildContext context, Tags f) {
    return GestureDetector(
      onLongPress: () async {
        await _longPressTag(context, f);
      },
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return ResultPage(
            word: f.name,
            translatedName: f.translatedName ?? "",
          );
        }));
      },
      child: Container(
        height: 25,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: const BorderRadius.all(Radius.circular(12.5)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RichText(
                textAlign: TextAlign.start,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                text: TextSpan(
                    text: "#${f.name}",
                    children: [
                      TextSpan(
                        text: " ",
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall!
                            .copyWith(fontSize: 12),
                      ),
                      if (f.translatedName != null)
                        TextSpan(
                            text: "${f.translatedName}",
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .copyWith(fontSize: 12))
                    ],
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 12))),
          ],
        ),
      ),
    );
  }

  Widget _buildNameAvatar(BuildContext context, Illusts illust) {
    if (userStore == null)
      userStore = UserStore(illust.user.id, null, illust.user);
    return Observer(builder: (_) {
      Future.delayed(Duration(seconds: 2), () {
        _loadAbout();
      });
      return InkWell(
        onTap: () async {
          await _push2UserPage(context, illust);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
                child: Hero(
                  tag: illust.user.profileImageUrls.medium +
                      this.hashCode.toString(),
                  child: PainterAvatar(
                    url: illust.user.profileImageUrls.medium,
                    id: illust.user.id,
                    size: Size(32, 32),
                    onTap: () async {
                      await Leader.push(
                          context,
                          UsersPage(
                            id: illust.user.id,
                            userStore: userStore,
                            heroTag: this.hashCode.toString(),
                          ));
                      _illustStore.illusts!.user.isFollowed =
                          userStore!.isFollow;
                    },
                  ),
                ),
                padding: EdgeInsets.only(left: 16.0)),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Hero(
                      tag: illust.user.name + this.hashCode.toString(),
                      child: SelectionArea(
                        child: Text(
                          illust.user.name,
                          style: TextStyle(
                              fontSize: 14,
                              color:
                                  Theme.of(context).textTheme.bodySmall!.color),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            UserFollowButton(
              followed: userStore?.isFollow ?? illust.user.isFollowed ?? false,
              onPressed: () async {
                await userStore?.follow();
                if (userStore?.isFollow != null) {
                  _illustStore.illusts?.user.isFollowed = userStore?.isFollow;
                }
              },
            ),
            SizedBox(
              width: 12,
            )
          ],
        ),
      );
    });
  }

  Future<void> _push2UserPage(BuildContext context, Illusts illust) async {
    await Leader.push(
        context,
        UsersPage(
          id: illust.user.id,
          userStore: userStore,
          heroTag: this.hashCode.toString(),
        ));
    _illustStore.illusts!.user.isFollowed = userStore!.isFollow;
  }

  Future<void> _pressSave(Illusts illust, int index) async {
    if (userSetting.illustDetailSaveSkipLongPress) {
      saveStore.saveImage(illust, index: index);
      if (userSetting.starAfterSave && (_illustStore.state == 0)) {
        _illustStore.star(
            restrict: userSetting.defaultPrivateLike ? "private" : "public");
      }
      return;
    }
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(16),
          ),
        ),
        builder: (c1) {
          return Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                illust.metaPages.isNotEmpty
                    ? ListTile(
                        title: Text(I18n.of(context).muti_choice_save),
                        leading: Icon(
                          Icons.save,
                        ),
                        onTap: () async {
                          Navigator.of(context).pop();
                          _showMutiChoiceDialog(illust, context);
                        },
                      )
                    : Container(),
                ListTile(
                  leading: Icon(Icons.save_alt),
                  onTap: () async {
                    Navigator.of(context).pop();
                    saveStore.saveImage(illust, index: index);
                    if (userSetting.starAfterSave &&
                        (_illustStore.state == 0)) {
                      _illustStore.star(
                          restrict: userSetting.defaultPrivateLike
                              ? "private"
                              : "public");
                    }
                  },
                  onLongPress: () async {
                    Navigator.of(context).pop();
                    saveStore.saveImage(illust, index: index);
                  },
                  title: Text(I18n.of(context).save),
                ),
                ListTile(
                  leading: Icon(Icons.cancel),
                  onTap: () => Navigator.of(context).pop(),
                  title: Text(I18n.of(context).cancel),
                ),
                Container(
                  height: MediaQuery.of(c1).padding.bottom,
                )
              ],
            ),
          );
        });
  }

  Future _showMutiChoiceDialog(Illusts illust, BuildContext context) async {
    List<bool> indexs = [];
    bool allOn = false;
    for (int i = 0; i < illust.metaPages.length; i++) {
      indexs.add(false);
    }
    final result = await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.0))),
        builder: (context) {
          return StatefulBuilder(builder: (context, setDialogState) {
            return SafeArea(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.8,
                child: Column(
                  children: [
                    Container(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(illust.title),
                      ),
                    ),
                    Expanded(
                      child: GridView.builder(
                        itemBuilder: (context, index) {
                          final data = illust.metaPages[index];
                          return Container(
                              child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: InkWell(
                              onTap: () {
                                setDialogState(() {
                                  indexs[index] = !indexs[index];
                                });
                              },
                              onLongPress: () {
                                Leader.push(
                                    context,
                                    PhotoZoomPage(
                                      index: index,
                                      illusts: illust,
                                      illustStore: _illustStore,
                                    ));
                              },
                              child: Stack(
                                children: [
                                  PixivImage(
                                    data.imageUrls!.squareMedium,
                                    placeWidget: Container(
                                      child: Center(
                                        child: Text(index.toString()),
                                      ),
                                    ),
                                  ),
                                  Align(
                                      alignment: Alignment.bottomRight,
                                      child: Visibility(
                                          visible: indexs[index],
                                          child: Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: Icon(
                                              Icons.check_circle,
                                              color: Colors.green,
                                            ),
                                          ))),
                                ],
                              ),
                            ),
                          ));
                        },
                        itemCount: illust.metaPages.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3),
                      ),
                    ),
                    ListTile(
                      leading: Icon(!allOn
                          ? Icons.check_circle_outline
                          : Icons.check_circle),
                      title: Text(I18n.of(context).all),
                      onTap: () {
                        allOn = !allOn;
                        for (var i = 0; i < indexs.length; i++) {
                          indexs[i] = allOn;
                        }
                        setDialogState(() {});
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.save),
                      title: Text(I18n.of(context).save),
                      onTap: () {
                        Navigator.of(context).pop("OK");
                        if (userSetting.starAfterSave &&
                            (_illustStore.state == 0)) {
                          _illustStore.star(
                              restrict: userSetting.defaultPrivateLike
                                  ? "private"
                                  : "public");
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          });
        });
    switch (result) {
      case "OK":
        {
          saveStore.saveChoiceImage(illust, indexs);
        }
    }
  }

  Future buildShowModalBottomSheet(BuildContext context, Illusts illusts) {
    return showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(16),
          ),
        ),
        builder: (_) {
          return Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8.0),
                    topRight: Radius.circular(8.0))),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(
                    height: 8,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      _buildNameAvatar(context, illusts),
                      if (illusts.metaPages.isNotEmpty)
                        ListTile(
                          title: Text(I18n.of(context).muti_choice_save),
                          leading: Icon(
                            Icons.save,
                          ),
                          onTap: () async {
                            Navigator.of(context).pop();
                            _showMutiChoiceDialog(illusts, context);
                          },
                        ),
                      ListTile(
                        title: Text(I18n.of(context).copymessage),
                        leading: Icon(
                          Icons.local_library,
                        ),
                        onTap: () async {
                          final str =
                              userSetting.illustToShareInfoText(illusts);
                          await Clipboard.setData(ClipboardData(text: str));
                          BotToast.showText(
                              text: I18n.of(context).copied_to_clipboard);
                          Navigator.of(context).pop();
                        },
                      ),
                      Builder(builder: (context) {
                        return ListTile(
                          title: Text(I18n.of(context).share),
                          leading: Icon(
                            Icons.share,
                          ),
                          onTap: () {
                            final box =
                                context.findRenderObject() as RenderBox?;
                            final pos = box != null
                                ? box.localToGlobal(Offset.zero) & box.size
                                : null;
                            Navigator.of(context).pop();
                            Share.share(
                                "https://www.pixiv.net/artworks/${widget.id}",
                                sharePositionOrigin: pos);
                          },
                        );
                      }),
                      ListTile(
                        leading: Icon(
                          Icons.link,
                        ),
                        title: Text(I18n.of(context).link),
                        onTap: () async {
                          await Clipboard.setData(ClipboardData(
                              text:
                                  "https://www.pixiv.net/artworks/${widget.id}"));
                          BotToast.showText(
                              text: I18n.of(context).copied_to_clipboard);
                          Navigator.of(context).pop();
                        },
                      ),
                      ListTile(
                        title: Text(I18n.of(context).ban),
                        leading: Icon(Icons.brightness_auto),
                        onTap: () {
                          muteStore.insertBanIllusts(BanIllustIdPersist(
                              illustId: widget.id.toString(),
                              name: illusts.title));
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        title: Text(I18n.of(context).report),
                        leading: Icon(Icons.report),
                        onTap: () async {
                          if (Platform.isAndroid) {
                            Navigator.of(context).pop();
                            await Reporter.show(
                                context,
                                () async => await muteStore.insertBanIllusts(
                                    BanIllustIdPersist(
                                        illustId: widget.id.toString(),
                                        name: illusts.title)));
                          } else {
                            await showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text(I18n.of(context).report),
                                    content:
                                        Text(I18n.of(context).report_message),
                                    actions: <Widget>[
                                      TextButton(
                                        child: Text(I18n.of(context).cancel),
                                        onPressed: () {
                                          Navigator.of(context).pop("CANCEL");
                                        },
                                      ),
                                      TextButton(
                                        child: Text(I18n.of(context).ok),
                                        onPressed: () {
                                          Navigator.of(context).pop("OK");
                                        },
                                      ),
                                    ],
                                  );
                                });
                          }
                        },
                      )
                    ],
                  ),
                  Container(
                    height: MediaQuery.of(context).padding.bottom,
                  )
                ],
              ),
            ),
          );
        });
  }

  Future<void> _showBookMarkTag() async {
    final result =
        await Leader.pushWithScaffold(context, TagForIllustPage(id: widget.id));
    if (result is Map) {
      LPrinter.d(result);
      String restrict = result['restrict'];
      List<String>? tags = result['tags'];
      if (userSetting.saveAfterStar && (_illustStore.state == 0)) {
        saveStore.saveImage(_illustStore.illusts!);
      }
      _illustStore.star(restrict: restrict, tags: tags, force: true);
    }
  }

  @override
  bool get wantKeepAlive => false;
}

class TextSelectionFix {
  static TextSelectionControls? buildControls(BuildContext context) {
    TextSelectionControls? controls = null;
    switch (Theme.of(context).platform) {
      case TargetPlatform.android:
      case TargetPlatform.ohos:
      case TargetPlatform.fuchsia:
        controls ??= materialTextSelectionControls;
        break;
      case TargetPlatform.iOS:
        controls ??= cupertinoTextSelectionControls;
        break;
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        controls ??= desktopTextSelectionControls;
        break;
      case TargetPlatform.macOS:
        controls ??= cupertinoDesktopTextSelectionControls;
        break;
    }
    return controls;
  }
}
