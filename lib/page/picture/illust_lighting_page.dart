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
import 'package:pixez/component/selectable_html.dart';
import 'package:pixez/component/star_icon.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/generated/l10n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/ban_illust_id.dart';
import 'package:pixez/models/ban_tag.dart';
import 'package:pixez/models/bookmark_detail.dart';
import 'package:pixez/models/illust.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/comment/comment_page.dart';
import 'package:pixez/page/picture/illust_about_store.dart';
import 'package:pixez/page/picture/illust_detail_store.dart';
import 'package:pixez/page/picture/illust_store.dart';
import 'package:pixez/exts.dart';
import 'package:pixez/page/picture/ugoira_loader.dart';
import 'package:pixez/page/search/result_page.dart';
import 'package:pixez/page/zoom/photo_viewer_page.dart';
import 'package:share/share.dart';

class IllustLightingPage extends StatefulWidget {
  final int id;
  final String heroString;
  final IllustStore store;

  const IllustLightingPage({Key key, this.id, this.heroString, this.store})
      : super(key: key);
  @override
  _IllustLightingPageState createState() => _IllustLightingPageState();
}

class _IllustLightingPageState extends State<IllustLightingPage> {
  IllustStore _illustStore;
  IllustAboutStore _aboutStore;
  ScrollController _scrollController;

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
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void _loadAbout() {
    if (mounted &&
        _scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        _aboutStore.illusts.isEmpty) _aboutStore.fetch();
  }

  @override
  void dispose() {
    _illustStore?.dispose();
    _scrollController?.dispose();
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
                            context, _illustStore.illusts);
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
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
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
  Widget _buildContent(BuildContext context, Illusts data) {
    if (data == null)
      return Container(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
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
            RaisedButton(
              onPressed: () {
                _illustStore.fetch();
              },
              child: Text(I18n.of(context).refresh),
            )
          ],
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
            child: Hero(
              tag: '${data.imageUrls.medium}${widget.heroString}',
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
                    child: Hero(
                      tag: '${data.imageUrls.medium}${widget.heroString}',
                      child: PixivImage(
                        url,
                        fade: false,
                        placeWidget: userSetting.pictureQuality == 1
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
            child: FlatButton(
              child: Text(
                I18n.of(context).view_comment,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: Theme.of(context).textTheme.bodyText1.fontSize),
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
                  RaisedButton(
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
                  return InkWell(
                    onTap: () {
                      Leader.push(
                          context,
                          IllustLightingPage(
                            id: _aboutStore.illusts[index].id,
                            store: IllustStore(_aboutStore.illusts[index].id,
                                _aboutStore.illusts[index]),
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
            ],
          );
        })) {
      case 0:
        {
          muteStore.insertBanTag(BanTagPersist()
            ..name = f.name
            ..translateName = f.translatedName ?? '_');
        }
        break;
      case 1:
        {
          bookTagStore.bookTag(f.name);
        }
        break;
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
            translatedName: f.translatedName ?? '',
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
                  .caption
                  .copyWith(color: Theme.of(context).accentColor))),
    );
  }

  Widget _buildNameAvatar(BuildContext context, Illusts illust) {
    IllustDetailStore illustDetailStore = IllustDetailStore(illust);
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

  Future _pressSave(Illusts illust, int index) {
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
              child: Text(I18n.of(context).cancel),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            FlatButton(
              onPressed: () {
                Navigator.pop(context, "OK");
              },
              child: Text(I18n.of(context).ok),
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
                contentPadding: EdgeInsets.all(0.0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8.0))),
                content: Container(
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
                                    -2,
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
                          padding: EdgeInsets.all(2.0),
                          itemCount: tags.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(bookMarkDetailResponse
                                        .bookmarkDetail.tags[index].name),
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
                            );
                          },
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(6.0),
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
                      if (mounted)
                        setState(() {}); //star请求不管成功或是失败都强刷一次外层ui，因为mobx影响不到
                    },
                  ),
                ],
              );
            },
          ));
  }
}
