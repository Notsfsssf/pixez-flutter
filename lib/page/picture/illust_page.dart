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
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/component/ban_page.dart';
import 'package:pixez/component/painter_avatar.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/component/star_icon.dart';
import 'package:pixez/exts.dart';
import 'package:pixez/generated/l10n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/ban_illust_id.dart';
import 'package:pixez/models/bookmark_detail.dart';
import 'package:pixez/models/illust.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/picture/illust_about_grid.dart';
import 'package:pixez/page/picture/illust_about_sliver.dart';
import 'package:pixez/page/picture/illust_detail_body.dart';
import 'package:pixez/page/picture/illust_detail_store.dart';
import 'package:pixez/page/picture/illust_store.dart';
import 'package:pixez/page/picture/ugoira_loader.dart';
import 'package:pixez/page/zoom/photo_viewer_page.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:share/share.dart';

class IllustPage extends StatefulWidget {
  final int id;
  final String heroString;
  final IllustStore store;

  const IllustPage({Key key, @required this.id, this.store, this.heroString})
      : super(key: key);

  @override
  _IllustPageState createState() => _IllustPageState();
}

class _IllustPageState extends State<IllustPage> {
  IllustStore _illustStore;
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

  @override
  void initState() {
    _illustStore = widget.store ?? IllustStore(widget.id, null);
    _illustStore.fetch();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _showBookMarkTag() async {
    if (_illustStore.isBookmark) {
      await _illustStore.star();
      setState(() {});
      return;
    }
    CancelFunc cancelFunc =
        BotToast.showLoading(clickClose: true, allowClick: true);
    Response response;
    try {
      response = await apiClient.getIllustBookmarkDetail(widget.id);
      cancelFunc();
    } catch (e) {
      cancelFunc();
      return;
    }
    BookMarkDetailResponse bookMarkDetailResponse =
        BookMarkDetailResponse.fromJson(response.data);
    if (mounted)
      showDialog(
          context: context,
          child: StatefulBuilder(
            builder: (_, setBookState) {
              final TextEditingController textEditingController =
                  TextEditingController();
              final List<TagsR> tags =
                  bookMarkDetailResponse.bookmarkDetail.tags;
              final detail = bookMarkDetailResponse.bookmarkDetail;
              return AlertDialog(
                contentPadding: EdgeInsets.all(2.0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0))),
                content: Container(
                  width: double.maxFinite,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      TextField(
                        controller: textEditingController,
                        decoration: InputDecoration(
                            suffixIcon: IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            final value =
                                textEditingController.value.text.trim();
                            if (value.isNotEmpty)
                              setBookState(() {
                                tags.insert(
                                    0,
                                    TagsR()
                                      ..name = value
                                      ..isRegistered = true);
                                textEditingController.clear();
                              });
                          },
                        )),
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.all(0.0),
                          itemCount: tags.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Flex(
                              direction: Axis.horizontal,
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    bookMarkDetailResponse
                                        .bookmarkDetail.tags[index].name,
                                    softWrap: true,
                                    maxLines: 1,
                                    textAlign: TextAlign.left,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Checkbox(
                                  onChanged: (bool value) {
                                    setBookState(() {
                                      bookMarkDetailResponse.bookmarkDetail
                                          .tags[index].isRegistered = value;
                                    });
                                  },
                                  value: bookMarkDetailResponse
                                      .bookmarkDetail.tags[index].isRegistered,
                                )
                              ],
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.max,
                            );
                          },
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text((detail.restrict == "public"
                                    ? I18n.of(context).public
                                    : I18n.of(context).private) +
                                I18n.of(context).bookmark),
                          ),
                          Switch(
                            onChanged: (bool value) {
                              setBookState(() {
                                detail.restrict = value ? "public" : "private";
                              });
                            },
                            value: detail.restrict == "public",
                          )
                        ],
                      )
                    ],
                  ),
                ),
                actions: <Widget>[
                  FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(I18n.of(context).cancel)),
                  FlatButton(
                    child: Text(I18n.of(context).ok),
                    onPressed: () async {
                      final tags = bookMarkDetailResponse.bookmarkDetail.tags;
                      List<String> tempTags = [];
                      for (int i = 0; i < tags.length; i++) {
                        if (tags[i].isRegistered) {
                          tempTags.add(tags[i].name);
                        }
                      }
                      if (tempTags.length == 0) tempTags = null;
                      Navigator.of(context).pop();
                      await _illustStore.star(
                          restrict:
                              bookMarkDetailResponse.bookmarkDetail.restrict,
                          tags: tempTags);

                      setState(() {}); //star请求不管成功或是失败都强刷一次外层ui，因为mobx影响不到
                    },
                  ),
                ],
              );
            },
          ));
  }

  Widget _buildNameAvatar(BuildContext context, Illusts illust) {
    IllustDetailStore illustDetailStore = IllustDetailStore(illust);
    return Observer(builder: (_) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
              child: GestureDetector(
                onLongPress: () {
                  illustDetailStore.followUser();
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
                                    color: illustDetailStore.isFollow
                                        ? Colors.yellow
                                        : Theme.of(context).accentColor,
                                  )
                                : BoxDecoration(),
                          ),
                        ),
                      ),
                      Center(
                        child: PainterAvatar(
                          url: illust.user.profileImageUrls.medium,
                          id: illust.user.id,
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
                  SelectableText(
                    illust.user.name,
                    style: Theme.of(context).textTheme.bodyText2,
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
                          muteStore.insertBanIllusts(BanIllustIdPersist()
                            ..illustId = widget.id.toString()
                            ..name = illusts.title);
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
                                    FlatButton(
                                      child: Text(I18n.of(context).cancel),
                                      onPressed: () {
                                        Navigator.of(context).pop("CANCEL");
                                      },
                                    ),
                                    FlatButton(
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

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      for (var i in muteStore.banillusts) {
        if (i.illustId == widget.id.toString()) {
          return BanPage(
            name: I18n.of(context).illust,
          );
        }
      }
      if (_illustStore.illusts != null) {
        for (var j in muteStore.banUserIds) {
          if (j.userId == _illustStore.illusts.user.id.toString()) {
            return BanPage(
              name: I18n.of(context).painter,
            );
          }
        }
        for (var t in muteStore.banTags) {
          for (var t1 in _illustStore.illusts.tags) {
            if (t.name == t1.name)
              return BanPage(
                name: I18n.of(context).tag,
              );
          }
        }
      }
      if (_illustStore.illusts != null) {
        final data = _illustStore.illusts;
        return Scaffold(
            // appBar: AppBar(
            //   backgroundColor: Colors.transparent,
            //   elevation: 0.0,
            //   actions: <Widget>[
            //     IconButton(
            //         icon: Icon(Icons.expand_less),
            //         onPressed: () {
            //           itemScrollController.scrollTo(
            //               index: _illustStore.illusts.pageCount + 1,
            //               duration: Duration(seconds: 1),
            //               curve: Curves.easeInOutCubic);
            //         }),
            //     IconButton(
            //         icon: Icon(Icons.more_vert),
            //         onPressed: () {
            //           buildShowModalBottomSheet(context, _illustStore.illusts);
            //         })
            //   ],
            // ),
            extendBodyBehindAppBar: true,
            extendBody: true,
            floatingActionButton: GestureDetector(
              onLongPress: () {
                _showBookMarkTag();
              },
              child: FloatingActionButton(
                heroTag: widget.id,
                backgroundColor: Colors.white,
                onPressed: () => _illustStore.star(),
                child: StarIcon(
                  illustStore: _illustStore,
                ),
              ),
            ),
            body: Stack(
              children: [
                _buildBody(context, data),
                Column(
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
                                    itemScrollController.scrollTo(
                                        index:
                                            _illustStore.illusts.pageCount + 1,
                                        duration: Duration(seconds: 1),
                                        curve: Curves.easeInOutCubic);
                                  }),
                              IconButton(
                                  icon: Icon(Icons.more_vert),
                                  onPressed: () {
                                    buildShowModalBottomSheet(
                                        context, _illustStore.illusts);
                                  })
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                )
              ],
            ));
      } else {
        if (_illustStore.errorMessage != null) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(':(',
                        style: Theme.of(context).textTheme.headline4),
                  ),
                  Text('${_illustStore.errorMessage}'),
                  RaisedButton(
                    onPressed: () {
                      _illustStore.fetch();
                    },
                    child: Text(I18n.of(context).refresh),
                  )
                ],
              ),
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(),
          body: Container(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        );
      }
    });
  }

  List<Widget> buildPage(BuildContext context, Illusts data) {
    if (data.pageCount == 1) {
      return [_inkWellPic(context, data, 0)];
    } else {
      List<Widget> result = [];
      for (var i = 0; i < data.metaPages.length; i++) {
        result.add(_inkWellPic(context, data, i));
      }
      return result;
    }
  }

  Widget _buildSliver(BuildContext context, Illusts data) {
    return CustomScrollView(
      slivers: [
        SliverList(
            delegate: SliverChildListDelegate([
          ...(data.type == "ugoira")
              ? [
                  UgoiraLoader(
                    id: widget.id,
                    illusts: data,
                  )
                ]
              : buildPage(context, data)
        ])),
        SliverToBoxAdapter(
          child: IllustDetailBody(
            illust: data,
          ),
        ),
        IllustAboutSliver(
          id: data.id,
        )
      ],
    );
  }

  Widget _buildBody(BuildContext context, Illusts data) {
    return ScrollablePositionedList.builder(
      itemCount: data.pageCount + 4,
      padding: EdgeInsets.all(0.0),
      itemScrollController: itemScrollController,
      itemPositionsListener: itemPositionsListener,
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          if (!userSetting.isBangs) return Container();
          return Container(height: MediaQuery.of(context).padding.top);
        }
        if (index <= data.pageCount) {
          if (data.type != "ugoira")
            return _inkWellPic(context, data, index);
          else
            return UgoiraLoader(
              id: widget.id,
              illusts: data,
            );
        }
        if (index == data.pageCount + 1) {
          return IllustDetailBody(
            illust: data,
          );
        }
        if (index == data.pageCount + 2) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(I18n.of(context).about_picture),
          );
        }
        if (index == data.pageCount + 3) {
          return IllustAboutGrid(
            id: widget.id,
          );
        }
        return Container();
      },
    );
  }

  Widget _inkWellPic(BuildContext context, Illusts data, int index) {
    return InkWell(
      child: buildPictures(context, data, index),
      onLongPress: () {
        final illust = data;
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
                        saveStore.saveImage(illust, index: index - 1);
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
      },
      onTap: () {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (BuildContext context) {
          return PhotoViewerPage(
            index: index - 1,
            illusts: data,
          );
        }));
      },
    );
  }

  Future _showMutiChoiceDialog(Illusts illust, BuildContext context) async {
    List<bool> indexs = List(illust.metaPages.length);
    bool allOn = false;
    for (int i = 0; i < illust.metaPages.length; i++) {
      indexs[i] = false;
    }
    final result = await showDialog(
      context: context,
      child: StatefulBuilder(builder: (context, setDialogState) {
        return AlertDialog(
          title: Text(I18n.of(context).muti_choice_save),
          actions: <Widget>[
            FlatButton(
              child: Text(I18n
                  .of(context)
                  .cancel),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            FlatButton(
              onPressed: () {
                Navigator.pop(context, "OK");
              },
              child: Text(I18n
                  .of(context)
                  .ok),
            ),
          ],
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemBuilder: (context, index) => index == 0
                  ? ListTile(
                      title: Text(I18n.of(context).all),
                      trailing: Checkbox(
                          value: allOn,
                          onChanged: (ischeck) {
                            setDialogState(() {
                              allOn = ischeck;
                              if (ischeck)
                                for (int i = 0; i < indexs.length; i++) {
                                  indexs[i] = true;
                                } //这真不是我要这么写的，谁知道这个格式化缩进这么奇怪
                              else {
                                for (int i = 0; i < indexs.length; i++) {
                                  indexs[i] = false;
                                }
                              }
                            });
                          }),
                    )
                  : ListTile(
                      title: Text((index - 1).toString()),
                      trailing: Checkbox(
                          value: indexs[index - 1],
                          onChanged: (ischeck) {
                            setDialogState(() {
                              indexs[index - 1] = ischeck;
                            });
                          }),
                    ),
              itemCount: illust.metaPages.length + 1,
            ),
          ),
        );
      }),
    );
    switch (result) {
      case "OK":
        {
          saveStore.saveChoiceImage(illust, indexs);
        }
    }
  }

  Widget buildPictures(BuildContext context, Illusts data, int index) {
    if (data.pageCount == 1 && userSetting.pictureQuality == 1) {
      return Hero(
        child: PixivImage(
          data.imageUrls.large,
          fade: false,
          placeWidget: PixivImage(
            data.imageUrls.medium,
            placeWidget: Container(
              height: 150,
              child: Center(child: CircularProgressIndicator()),
            ),
            fade: false,
          ),
        ),
        tag: '${data.imageUrls.medium}${widget.heroString}',
      );
    }
    return (data.pageCount == 1)
        ? Hero(
            child: PixivImage(
              data.imageUrls.medium,
              fade: false,
              placeWidget: Container(
                height: 150,
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
            tag: '${data.imageUrls.medium}${widget.heroString}',
          )
        : _buildIllustsItem(index - 1, data);
  }

  Widget _buildIllustsItem(int index, Illusts illust) {
    return index == 0
        ? (userSetting.pictureQuality == 1
            ? Hero(
                child: PixivImage(
                  illust.metaPages[index].imageUrls.large,
                  placeWidget: PixivImage(
                    illust.metaPages[index].imageUrls.medium,
                    fade: false,
                  ),
                  fade: false,
                ),
                tag: '${illust.imageUrls.medium}${widget.heroString}',
              )
            : Hero(
                child: PixivImage(
                  illust.metaPages[index].imageUrls.medium,
                  fade: false,
                  placeWidget: PixivImage(
                    illust.metaPages[index].imageUrls.medium,
                    fade: false,
                  ),
                ),
                tag: '${illust.imageUrls.medium}${widget.heroString}',
              ))
        : PixivImage(
            userSetting.pictureQuality == 0
                ? illust.metaPages[index].imageUrls.medium
                : illust.metaPages[index].imageUrls.large,
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
}
