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
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/component/ban_page.dart';
import 'package:pixez/component/null_hero.dart';
import 'package:pixez/component/painter_avatar.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/component/selectable_html.dart';
import 'package:pixez/component/star_icon.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/er/lprinter.dart';
import 'package:pixez/exts.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/ban_illust_id.dart';
import 'package:pixez/models/ban_tag.dart';
import 'package:pixez/models/illust.dart';
import 'package:pixez/page/comment/comment_page.dart';
import 'package:pixez/page/picture/illust_about_store.dart';
import 'package:pixez/page/picture/illust_store.dart';
import 'package:pixez/page/picture/picture_list_page.dart';
import 'package:pixez/page/picture/tag_for_illust_page.dart';
import 'package:pixez/page/picture/ugoira_loader.dart';
import 'package:pixez/page/search/result_page.dart';
import 'package:pixez/page/user/user_store.dart';
import 'package:pixez/page/user/users_page.dart';
import 'package:pixez/page/zoom/photo_viewer_page.dart';
import 'package:share/share.dart';

class IllustLightingPage extends StatefulWidget {
  final int id;
  final String? heroString;
  final IllustStore? store;

  const IllustLightingPage(
      {Key? key, required this.id, this.heroString, this.store})
      : super(key: key);

  @override
  _IllustLightingPageState createState() => _IllustLightingPageState();
}

class _IllustLightingPageState extends State<IllustLightingPage>
    with AutomaticKeepAliveClientMixin {
  UserStore? userStore;
  late IllustStore _illustStore;
  late IllustAboutStore _aboutStore;
  late ScrollController _scrollController;

  @override
  void initState() {
    _scrollController = ScrollController();
    _illustStore = widget.store ?? IllustStore(widget.id, null);
    _illustStore.fetch();
    _aboutStore = IllustAboutStore(widget.id);
    super.initState();
    _scrollController.addListener(() => _loadAbout());
  }

  @override
  void didUpdateWidget(covariant IllustLightingPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.store != widget.store) {
      _illustStore = widget.store ?? IllustStore(widget.id, null);
      _illustStore.fetch();
      _aboutStore = IllustAboutStore(widget.id);
      LPrinter.d("state change");
    }
  }

  void _loadAbout() {
    if (mounted &&
        _scrollController.hasClients &&
        _scrollController.offset + 20 >=
            _scrollController.position.maxScrollExtent &&
        _aboutStore.illusts.isEmpty) _aboutStore.fetch();
  }

  @override
  void dispose() {
    _illustStore.dispose();
    _scrollController.dispose();
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
              IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.of(context).pop();
                  }),
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

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      floatingActionButton: GestureDetector(
        onLongPress: () {
          _showBookMarkTag();
        },
        child: Observer(builder: (context) {
          return Visibility(
            visible: _illustStore.errorMessage == null,
            child: FloatingActionButton(
              heroTag: widget.id,
              backgroundColor: Colors.white,
              onPressed: () => _illustStore.star(),
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
        for (var i in muteStore.banillusts) {
          if (i.illustId == widget.id.toString()) {
            return BanPage(
              name: I18n.of(context).illust,
            );
          }
        }
        if (_illustStore.illusts != null) {
          for (var j in muteStore.banUserIds) {
            if (j.userId == _illustStore.illusts!.user.id.toString()) {
              return BanPage(
                name: I18n.of(context).painter,
              );
            }
          }
          for (var t in muteStore.banTags) {
            for (var t1 in _illustStore.illusts!.tags) {
              if (t.name == t1.name)
                return BanPage(
                  name: I18n.of(context).tag,
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
    );
  }

  Widget colorText(String text, BuildContext context) => SelectableText(
        text,
        style: TextStyle(color: Theme.of(context).accentColor),
      );

  ScrollController scrollController = ScrollController();

  Widget _buildContent(BuildContext context, Illusts? data) {
    if (_illustStore.errorMessage != null)
      return Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(':(', style: Theme.of(context).textTheme.headline4),
            ),
            Text('${_illustStore.errorMessage}'),
            ElevatedButton(
              onPressed: () {
                _illustStore.fetch();
              },
              child: Text(I18n.of(context).refresh),
            )
          ],
        ),
      );
    if (data == null)
      return Container(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        if (userSetting.isBangs)
          SliverToBoxAdapter(
              child: Container(height: MediaQuery.of(context).padding.top)),
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
                  Widget placeWidget = Container(
                    height: 150,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                  return InkWell(
                    onLongPress: () {
                      _pressSave(data, 0);
                    },
                    onTap: () {
                      Leader.push(
                          context,
                          PhotoViewerPage(
                            index: 0,
                            illusts: data,
                          ));
                    },
                    child: NullHero(
                      tag: widget.heroString,
                      child: PixivImage(
                        url,
                        fade: false,
                        placeWidget: (url != data.imageUrls.medium)
                            ? PixivImage(
                                data.imageUrls.medium,
                                placeWidget: placeWidget,
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
                            PhotoViewerPage(
                              index: index,
                              illusts: data,
                            ));
                      },
                      child: _buildIllustsItem(index, data));
                }, childCount: data.metaPages.length)),
        SliverToBoxAdapter(
          child: _buildNameAvatar(context, data),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(I18n.of(context).illust_id),
                    Container(
                      width: 10.0,
                    ),
                    colorText(data.id.toString(), context),
                    Container(
                      width: 20.0,
                    ),
                    Text(I18n.of(context).pixel),
                    Container(
                      width: 10.0,
                    ),
                    colorText("${data.width}x${data.height}", context)
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(I18n.of(context).total_view),
                    Container(
                      width: 10.0,
                    ),
                    colorText(data.totalView.toString(), context),
                    Container(
                      width: 20.0,
                    ),
                    Text(I18n.of(context).total_bookmark),
                    Container(
                      width: 10.0,
                    ),
                    colorText("${data.totalBookmarks}", context)
                  ],
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 2,
              runSpacing: 0,
              children: [for (var f in data.tags) buildRow(context, f)],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SelectableHtml(
                data: data.caption.isEmpty ? "~" : data.caption,
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextButton(
              child: Text(
                I18n.of(context).view_comment,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyText1!,
              ),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => CommentPage(
                          id: data.id,
                        )));
              },
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(I18n.of(context).about_picture),
          ),
        ),
        if (_aboutStore.errorMessage != null)
          SliverToBoxAdapter(
            child: Container(
              height: 300,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(':(',
                        style: Theme.of(context).textTheme.headline4),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _aboutStore.fetch();
                    },
                    child: Text('Refresh'),
                  )
                ],
              ),
            ),
          ),
        _aboutStore.illusts.isNotEmpty
            ? SliverGrid(
                delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                  var list = _aboutStore.illusts
                      .map((element) => IllustStore(element.id, element))
                      .toList();
                  return InkWell(
                    onTap: () {
                      Leader.push(
                          context,
                          PictureListPage(
                            iStores: list,
                            store: list[index],
                          ));
                    },
                    child: PixivImage(
                      _aboutStore.illusts[index].imageUrls.squareMedium,
                      enableMemoryCache: false,
                    ),
                  );
                }, childCount: _aboutStore.illusts.length),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3))
            : SliverToBoxAdapter(
                child: Container(
                  height: 200,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              )
      ],
    );
  }

  Widget _buildIllustsItem(int index, Illusts illust) {
    final radio = illust.height.toDouble() / illust.width.toDouble();
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
              fade: false,
            ),
            fade: false,
          ),
          tag: widget.heroString,
        );
      return PixivImage(
        url,
        fade: false,
        placeWidget: Container(
          height: MediaQuery.of(context).size.width * radio,
          child: Center(
            child: Text('$index', style: Theme.of(context).textTheme.headline4),
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
                    style: Theme.of(context).textTheme.headline4),
              ),
            ),
          );
  }

  Future _longPressTag(BuildContext context, Tags f) async {
    switch (await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: Text(f.name),
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
      child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
              text: "#${f.name}",
              children: [
                TextSpan(
                  text: " ",
                  style: Theme.of(context).textTheme.caption,
                ),
                TextSpan(
                    text: "${f.translatedName ?? "~"}",
                    style: Theme.of(context).textTheme.caption)
              ],
              style: Theme.of(context)
                  .textTheme
                  .caption!
                  .copyWith(color: Theme.of(context).accentColor))),
    );
  }

  Widget _buildNameAvatar(BuildContext context, Illusts illust) {
    if (userStore == null)
      userStore = UserStore(illust.user.id, user: illust.user);
    return Observer(builder: (_) {
      Future.delayed(Duration(seconds: 2), () {
        _loadAbout();
      });
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
              child: GestureDetector(
                onLongPress: () {
                  userStore!.follow();
                },
                child: Container(
                  height: 70,
                  width: 70,
                  child: Stack(
                    children: <Widget>[
                      Center(
                        child: SizedBox(
                          height: 70,
                          width: 70,
                          child: Container(
                            decoration: illust != null
                                ? BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: userStore!.isFollow
                                        ? Colors.yellow
                                        : Theme.of(context).accentColor,
                                  )
                                : BoxDecoration(),
                          ),
                        ),
                      ),
                      Center(
                        child: Hero(
                          tag: illust.user.profileImageUrls.medium +
                              this.hashCode.toString(),
                          child: PainterAvatar(
                            url: illust.user.profileImageUrls.medium,
                            id: illust.user.id,
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
                      ),
                    ],
                  ),
                ),
              ),
              padding: EdgeInsets.all(8.0)),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SelectableText(
                    illust.title,
                    style: TextStyle(color: Theme.of(context).accentColor),
                  ),
                  Container(
                    height: 4.0,
                  ),
                  Hero(
                    tag: illust.user.name + this.hashCode.toString(),
                    child: SelectableText(
                      illust.user.name,
                      style: Theme.of(context).textTheme.bodyText2,
                    ),
                  ),
                  Text(
                    illust.createDate.toShortTime(),
                    style: Theme.of(context).textTheme.caption,
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

  Future<void> _pressSave(Illusts illust, int index) async {
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
                                    PhotoViewerPage(
                                        index: index, illusts: illust));
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
                      title: Text(I18n.of(context).ok),
                      onTap: () {
                        Navigator.of(context).pop("OK");
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
                          await Clipboard.setData(ClipboardData(
                              text:
                                  'title:${illusts.title}\npainter:${illusts.user.name}\nillust id:${widget.id}'));
                          BotToast.showText(
                              text: I18n.of(context).copied_to_clipboard);
                          Navigator.of(context).pop();
                        },
                      ),
                      ListTile(
                        title: Text(I18n.of(context).share),
                        leading: Icon(
                          Icons.share,
                        ),
                        onTap: () {
                          Navigator.of(context).pop();
                          Share.share(
                              "https://www.pixiv.net/artworks/${widget.id}");
                        },
                      ),
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
      _illustStore.star(restrict: restrict, tags: tags, force: true);
    }
  }

  @override
  bool get wantKeepAlive => false;
}
