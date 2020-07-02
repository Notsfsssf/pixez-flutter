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
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pixez/bloc/bloc.dart';
import 'package:pixez/bloc/illust_persist_bloc.dart';
import 'package:pixez/bloc/illust_persist_event.dart';
import 'package:pixez/component/ban_page.dart';
import 'package:pixez/component/painter_avatar.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/component/selectable_html.dart';
import 'package:pixez/component/star_icon.dart';
import 'package:pixez/component/ugoira_painter.dart';
import 'package:pixez/generated/l10n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/bookmark_detail.dart';
import 'package:pixez/models/illust.dart';
import 'package:pixez/models/ugoira_metadata_response.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/comment/comment_page.dart';
import 'package:pixez/page/picture/bloc/bloc.dart';
import 'package:pixez/page/search/result_page.dart';
import 'package:pixez/page/zoom/photo_viewer_page.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:share/share.dart';

abstract class ListItem {}

class IllustsItem implements ListItem {}

class DetailItem implements ListItem {}

class PicturePage extends StatefulWidget {
  final Illusts _illusts;
  final int id;
  final String heroString;

  PicturePage(this._illusts, this.id, {this.heroString});

  @override
  _PicturePageState createState() => _PicturePageState();
}

class _PicturePageState extends State<PicturePage> {
  _showBookMarkDetailDialog(BuildContext context, BookmarkDetailState state,
      PictureState snapshot, IllustState illustState) {
    showDialog(
        context: context,
        child: StatefulBuilder(
          builder: (_, setBookState) {
            final TextEditingController textEditingController =
                TextEditingController();
            if (state is DataBookmarkDetailState) {
              final List<TagsR> tags =
                  state.bookMarkDetailResponse.bookmarkDetail.tags;
              final detail = state.bookMarkDetailResponse.bookmarkDetail;
              return AlertDialog(
                contentPadding: EdgeInsets.all(2.0),
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
                          itemCount: tags.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Flex(
                              direction: Axis.horizontal,
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    state.bookMarkDetailResponse.bookmarkDetail
                                        .tags[index].name,
                                    softWrap: true,
                                    maxLines: 1,
                                    textAlign: TextAlign.left,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Checkbox(
                                  onChanged: (bool value) {
                                    setBookState(() {
                                      state
                                          .bookMarkDetailResponse
                                          .bookmarkDetail
                                          .tags[index]
                                          .isRegistered = value;
                                    });
                                  },
                                  value: state.bookMarkDetailResponse
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
                          Text((detail.restrict == "public"
                                  ? I18n.of(context).Public
                                  : I18n.of(context).Private) +
                              I18n.of(context).BookMark),
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
                    child: Text("Ok"),
                    onPressed: () {
                      Navigator.of(context).pop();
                      final tags =
                          state.bookMarkDetailResponse.bookmarkDetail.tags;
                      List<String> tempTags = [];
                      for (int i = 0; i < tags.length; i++) {
                        if (tags[i].isRegistered) {
                          tempTags.add(tags[i].name);
                        }
                      }
                      if (tempTags.length == 0) tempTags = null;

                      if (snapshot is DataState) {
                        BlocProvider.of<PictureBloc>(context).add(
                            StarPictureEvent(
                                snapshot.illusts,
                                state.bookMarkDetailResponse.bookmarkDetail
                                    .restrict,
                                tempTags));
                      } else {
                        if (illustState is DataIllustState)
                          BlocProvider.of<PictureBloc>(context).add(
                              StarPictureEvent(
                                  illustState.illusts,
                                  state.bookMarkDetailResponse.bookmarkDetail
                                      .restrict,
                                  tempTags));
                      }
                    },
                  )
                ],
              );
            } else
              return Container();
          },
        ));
  }

  static const platform = const MethodChannel('samples.flutter.dev/battery');

  @override
  void initState() {
    super.initState();
  }

  bool _playButtonVisible = true;

  @override
  void dispose() {
    super.dispose();
  }

  String toShortTime(String dateString) {
    try {
      var formatter = new DateFormat('yyyy-MM-dd HH:mm:ss');
      return formatter.format(DateTime.parse(dateString));
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MuteBloc, MuteState>(
        builder: (context, MuteState muteState) {
      if (muteState is DataMuteState) {
        for (var i in muteState.banIllustIds) {
          if (i.illustId == widget.id.toString()) {
            return BanPage(
              name: I18n.of(context).Illust,
            );
          }
        }
        if (widget._illusts != null) {
          for (var j in muteStore.banUserIds) {
            if (j.userId == widget._illusts.user.id.toString()) {
              return BanPage(
                name: I18n.of(context).Painter,
              );
            }
          }
          for (var t in muteState.banTags) {
            for (var t1 in widget._illusts.tags) {
              if (t.name == t1.name)
                return BanPage(
                  name: I18n.of(context).Tag,
                );
            }
          }
        }
      }
      return MultiBlocProvider(
          providers: [
            BlocProvider<PictureBloc>(
              create: (context) =>
                  PictureBloc(RepositoryProvider.of<ApiClient>(context)),
            ),
            BlocProvider<BookmarkDetailBloc>(
              create: (BuildContext context) =>
                  BookmarkDetailBloc(RepositoryProvider.of<ApiClient>(context)),
            ),
            BlocProvider<IllustBloc>(
              create: (BuildContext context) =>
                  IllustBloc(ApiClient(), widget.id, illust: widget._illusts)
                    ..add(FetchIllustDetailEvent()),
            ),
            BlocProvider<IllustRelatedBloc>(
              create: (context) =>
                  IllustRelatedBloc(RepositoryProvider.of<ApiClient>(context))
                    ..add(FetchRelatedEvent(widget.id)),
            ),
            BlocProvider<UgoiraMetadataBloc>(
              create: (context) =>
                  UgoiraMetadataBloc(RepositoryProvider.of<ApiClient>(context)),
            )
          ],
          child: BlocBuilder<PictureBloc, PictureState>(
              builder: (context, snapshot) {
            return Scaffold(
              extendBodyBehindAppBar: true,
              extendBody: true,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0.0,
                actions: <Widget>[
                  IconButton(
                      icon: Icon(Icons.expand_less),
                      onPressed: () {
                        var illustState =
                            BlocProvider.of<IllustBloc>(context).state;
                        if (illustState is DataIllustState)
                          itemScrollController.scrollTo(
                              index: illustState.illusts.pageCount + 1,
                              duration: Duration(seconds: 1),
                              curve: Curves.easeInOutCubic);
                      }),
                  IconButton(
                      icon: Icon(Icons.more_vert),
                      onPressed: () {
                        var illustState =
                            BlocProvider.of<IllustBloc>(context).state;
                        if (illustState is DataIllustState)
                          buildShowModalBottomSheet(
                              context, illustState.illusts);
                      })
                ],
              ),
              body: BlocBuilder<IllustBloc, IllustState>(
                  builder: (context, illustState) {
                if (illustState is FZFIllustState) {
                  return Container(
                      child: Center(
                    child: Text(illustState.errorMessage.error.user_message),
                  ));
                }
                if (illustState is DataIllustState) {
                  if (muteState is DataMuteState && widget._illusts == null) {
                    for (var j in muteStore.banUserIds) {
                      if (j.userId == illustState.illusts.user.id.toString()) {
                        return BanPage(
                          name: I18n.of(context).Painter,
                        );
                      }
                    }
                    for (var t in muteState.banTags) {
                      for (var t1 in illustState.illusts.tags) {
                        if (t.name == t1.name)
                          return BanPage(
                            name: I18n.of(context).Tag,
                          );
                      }
                    }
                  }
                  BlocProvider.of<IllustPersistBloc>(context)
                      .add(InsertIllustPersistEvent(illustState.illusts));
                  return MultiBlocListener(
                    listeners: [
                      BlocListener<BookmarkDetailBloc, BookmarkDetailState>(
                        listener:
                            (BuildContext context, BookmarkDetailState state) {
                          if (state is DataBookmarkDetailState)
                            _showBookMarkDetailDialog(
                                context, state, snapshot, illustState);
                        },
                      )
                    ],
                    child:
                        _buildList(context, illustState.illusts, illustState),
                  );
                } else
                  return Center(
                    child: CircularProgressIndicator(),
                  );
              }),
              floatingActionButton: BlocBuilder<IllustBloc, IllustState>(
                  builder: (context, illustState) {
                if (illustState is DataIllustState) {
                  var resultBool = ((snapshot is DataState)
                          ? snapshot.illusts.type == 'ugoira'
                          : illustState.illusts.type == 'ugoira') &&
                      _playButtonVisible;
                  return InkWell(
                      splashColor: Colors.blue,
                      onLongPress: () {
                        BlocProvider.of<BookmarkDetailBloc>(context).add(
                            FetchBookmarkDetailEvent(illustState.illusts.id));
                      },
                      onTap: () {},
                      child: resultBool
                          ? FloatingActionButton.extended(
                              onPressed: () {
                                BlocProvider.of<PictureBloc>(context).add(
                                    StarPictureEvent(
                                        (snapshot is DataState)
                                            ? snapshot.illusts
                                            : illustState.illusts,
                                        "public",
                                        null));
                              },
                              backgroundColor: Colors.white,
                              icon: StarIcon((snapshot is DataState)
                                  ? snapshot.illusts.isBookmarked
                                  : illustState.illusts.isBookmarked),
                              label: FlatButton(
                                padding: EdgeInsets.all(0.0),
                                child: Text('Play'),
                                onPressed: () {
                                  BlocProvider.of<UgoiraMetadataBloc>(context)
                                      .add(FetchUgoiraMetadataEvent(widget.id));
                                  setState(() {
                                    _playButtonVisible = false;
                                  });
                                },
                              ),
                            )
                          : FloatingActionButton(
                              heroTag: widget.id,
                              backgroundColor: Colors.white,
                              child: StarIcon((snapshot is DataState)
                                  ? snapshot.illusts.isBookmarked
                                  : illustState.illusts.isBookmarked),
                              onPressed: () {
                                BlocProvider.of<PictureBloc>(context).add(
                                    StarPictureEvent(
                                        (snapshot is DataState)
                                            ? snapshot.illusts
                                            : illustState.illusts,
                                        "public",
                                        null));
                              },
                            ));
                }

                return FloatingActionButton(
                  heroTag: DateTime.now().toIso8601String(),
                  child: Icon(Icons.reply),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                );
              }),
            );
          }));
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
                      illusts.metaPages.isNotEmpty
                          ? ListTile(
                              title: Text(I18n.of(context).Muti_Choice_save),
                              leading: Icon(
                                Icons.save,
                              ),
                              onTap: () async {
                                Navigator.of(context).pop();
                                List<bool> indexs =
                                    List(illusts.metaPages.length);
                                for (int i = 0;
                                    i < illusts.metaPages.length;
                                    i++) {
                                  indexs[i] = false;
                                }
                                final result = await showDialog(
                                  context: context,
                                  child: StatefulBuilder(
                                      builder: (context, setDialogState) {
                                    return AlertDialog(
                                      title: Text("Select"),
                                      actions: <Widget>[
                                        FlatButton(
                                          onPressed: () {
                                            Navigator.pop(context, "OK");
                                          },
                                          child: Text(I18n.of(context).OK),
                                        ),
                                        FlatButton(
                                          child: Text(I18n.of(context).Cancel),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                        )
                                      ],
                                      content: Container(
                                        width: double.maxFinite,
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          itemBuilder: (context, index) {
                                            return ListTile(
                                              title: Text(index.toString()),
                                              trailing: Checkbox(
                                                  value: indexs[index],
                                                  onChanged: (ischeck) {
                                                    setDialogState(() {
                                                      indexs[index] = ischeck;
                                                    });
                                                  }),
                                            );
                                          },
                                          itemCount: illusts.metaPages.length,
                                        ),
                                      ),
                                    );
                                  }),
                                );
                                switch (result) {
                                  case "OK":
                                    {
                                      saveStore.saveChoiceImage(
                                          illusts, indexs);
                                    }
                                }
                              },
                            )
                          : Container(),
                      ListTile(
                        title: Text(I18n.of(context).CopyMessage),
                        leading: Icon(
                          Icons.local_library,
                        ),
                        onTap: () async {
                          await Clipboard.setData(ClipboardData(
                              text:
                                  'title:${illusts.title}\npainter:${illusts.user.name}\nillust id:${widget.id}'));
                          BotToast.showText(
                              text: I18n.of(context).Copied_To_Clipboard);
                          Navigator.of(context).pop();
                        },
                      ),
                      ListTile(
                        title: Text(I18n.of(context).Share),
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
                        title: Text(I18n.of(context).Ban),
                        leading: Icon(Icons.brightness_auto),
                        onTap: () {
                          BlocProvider.of<MuteBloc>(context).add(
                              InsertBanIllustEvent(
                                  widget.id.toString(), illusts.title));
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        title: Text(I18n.of(context).report),
                        leading: Icon(Icons.report),
                        onTap: () async {
                          await showCupertinoDialog(
                              context: context,
                              builder: (context) {
                                return CupertinoAlertDialog(
                                  title: Text(I18n.of(context).report),
                                  content:
                                      Text(I18n.of(context).Report_Message),
                                  actions: <Widget>[
                                    CupertinoDialogAction(
                                      isDefaultAction: true,
                                      child: Text("OK"),
                                      onPressed: () {
                                        Navigator.of(context).pop("OK");
                                      },
                                    ),
                                    CupertinoDialogAction(
                                      child: Text("CANCEL"),
                                      onPressed: () {
                                        Navigator.of(context).pop("CANCEL");
                                      },
                                    ),
                                  ],
                                );
                              });
                        },
                      )
                    ],
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.cancel,
                    ),
                    title: Text(I18n.of(context).Cancel),
                    onTap: () {
                      Navigator.of(context).pop();
                    },
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

  Widget _buildIllustsItem(int index, Illusts illust) => index == 0
      ? Hero(
          child: PixivImage(
            illust.metaPages[index].imageUrls.large,
            placeHolder: illust.metaPages[index].imageUrls.medium,
          ),
          tag: '${illust.imageUrls.medium}${widget.heroString}',
        )
      : PixivImage(
          illust.metaPages[index].imageUrls.large,
        );

  Widget _buildGridView(DataIllustState illustState) =>
      BlocBuilder<IllustRelatedBloc, IllustRelatedState>(
          builder: (context, snapshot) {
        if (snapshot is DataIllustRelatedState)
          return GridView.builder(
              padding: EdgeInsets.all(0.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, //
              ),
              shrinkWrap: true,
              itemCount: snapshot.recommend.illusts.length,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (BuildContext context) {
                      return PicturePage(snapshot.recommend.illusts[index],
                          snapshot.recommend.illusts[index].id);
                    }));
                  },
                  child: PixivImage(
                      snapshot.recommend.illusts[index].imageUrls.squareMedium),
                );
              });
        else
          return Center(
            child: CircularProgressIndicator(),
          );
      });
  Illusts _illusts;
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
  Widget _buildList(context, Illusts illust, DataIllustState illustState) {
    final count = illust.metaPages.isEmpty ? 1 : illust.metaPages.length;
    _illusts = illust;

    return ScrollablePositionedList.builder(
        itemScrollController: itemScrollController,
        itemPositionsListener: itemPositionsListener,
        itemCount: count + 4,
        padding: EdgeInsets.all(0.0),
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return Container(
                height: MediaQuery.of(context).padding.top - 56 //??
                );
          }
          if (index == count + 1) {
            return _buildDetail(context, illust);
          }
          if (index == count + 2) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(I18n.of(context).About_Picture),
            );
          }
          if (index == count + 3) {
            return _buildGridView(illustState);
          }

          if (illust.type == "ugoira" && index == 1) {
            _playButtonVisible = true;
            return BlocBuilder<UgoiraMetadataBloc, UgoiraMetadataState>(
                builder: (context, snapshot) {
              if (snapshot is DownLoadProgressState) {
                return Container(
                  height: 200,
                  child: Center(
                    child: CircularProgressIndicator(
                      value: snapshot.count / snapshot.total,
                    ),
                  ),
                );
              }
              if (snapshot is PlayUgoiraMetadataState) {
                List<Frame> frames = snapshot.frames;
                debugPrint('radio:' +
                    ((illust.height.toDouble() / illust.width.toDouble()) *
                            MediaQuery.of(context).size.width)
                        .toString() +
                    "width:" +
                    MediaQuery.of(context).size.width.toString());
                return InkWell(
                  onTap: () async {
                    final result = await showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text("Encode?"),
                            content: Text("This will take some time"),
                            actions: <Widget>[
                              FlatButton(
                                child: Text("OK"),
                                onPressed: () {
                                  Navigator.of(context).pop("OK");
                                },
                              ),
                              FlatButton(
                                child: Text("CANCEL"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              )
                            ],
                          );
                        });
                    if (result == "OK") {
                      try {
                        platform.invokeMethod('getBatteryLevel', {
                          "path": snapshot.listSync.first.parent.path,
                          "delay": snapshot.frames.first.delay,
                          "name": widget.id.toString()
                        });
                        BotToast.showCustomText(
                            toastBuilder: (_) => Text("encoding..."));
                      } on PlatformException catch (e) {}
                    }
                  },
                  onLongPress: () async {
                    final result = await showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text("Encode?"),
                            content: Text("This will take some time"),
                            actions: <Widget>[
                              FlatButton(
                                child: Text("OK"),
                                onPressed: () {
                                  Navigator.of(context).pop("OK");
                                },
                              ),
                              FlatButton(
                                child: Text("CANCEL"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              )
                            ],
                          );
                        });
                    if (result == "OK") {
                      try {
                        platform.invokeMethod('getBatteryLevel', {
                          "path": snapshot.listSync.first.parent.path,
                          "delay": snapshot.frames.first.delay,
                          "name": widget._illusts.id.toString()
                        });
                        BotToast.showCustomText(
                            toastBuilder: (_) => Text("encoding..."));
                      } on PlatformException catch (e) {}
                    }
                  },
                  child: Container(
                    height:
                        (illust.height.toDouble() / illust.width.toDouble()) *
                            MediaQuery.of(context).size.width.toDouble(),
                    width: MediaQuery.of(context).size.width.toDouble(),
                    child: UgoiraWidget(
                      size: Size(
                          MediaQuery.of(context).size.width.toDouble(),
                          (illust.height.toDouble() / illust.width.toDouble()) *
                              MediaQuery.of(context).size.width.toDouble()),
                      drawPools: snapshot.listSync,
                      delay: frames.first.delay,
                    ),
                  ),
                );
                // return UgoiraAnima(snapshot.listSync,snapshot.frames);
              }
              return PixivImage(
                illust.imageUrls.medium,
              );
            });
          }
          return GestureDetector(
            onLongPress: () {
              final isFileExist =
                  saveStore.isIllustPartExist(illust, index: index - 1);
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
                          Platform.isAndroid
                              ? ListTile(
                                  title: Text(illust.title),
                                  subtitle: isFileExist == null
                                      ? Text(I18n.of(context).Unsaved)
                                      : Text(
                                          '${I18n.of(context).Already_Saved} ${isFileExist.toString()}'),
                                  trailing: isFileExist == null
                                      ? Icon(Icons.info)
                                      : Icon(
                                          Icons.check_circle,
                                          color: Colors.green,
                                        ),
                                )
                              : Container(),
                          illust.metaPages.isNotEmpty
                              ? ListTile(
                                  title:
                                      Text(I18n.of(context).Muti_Choice_save),
                                  leading: Icon(
                                    Icons.save,
                                  ),
                                  onTap: () async {
                                    Navigator.of(context).pop();
                                    List<bool> indexs =
                                        List(illust.metaPages.length);
                                    for (int i = 0;
                                        i < illust.metaPages.length;
                                        i++) {
                                      indexs[i] = false;
                                    }
                                    final result = await showDialog(
                                      context: context,
                                      child: StatefulBuilder(
                                          builder: (context, setDialogState) {
                                        return AlertDialog(
                                          title: Text("Select"),
                                          actions: <Widget>[
                                            FlatButton(
                                              onPressed: () {
                                                Navigator.pop(context, "OK");
                                              },
                                              child: Text(I18n.of(context).OK),
                                            ),
                                            FlatButton(
                                              child:
                                                  Text(I18n.of(context).Cancel),
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                            )
                                          ],
                                          content: Container(
                                            width: double.maxFinite,
                                            child: ListView.builder(
                                              shrinkWrap: true,
                                              itemBuilder: (context, index) =>
                                                  ListTile(
                                                title: Text(index.toString()),
                                                trailing: Checkbox(
                                                    value: indexs[index],
                                                    onChanged: (ischeck) {
                                                      setDialogState(() {
                                                        indexs[index] = ischeck;
                                                      });
                                                    }),
                                              ),
                                              itemCount:
                                                  illust.metaPages.length,
                                            ),
                                          ),
                                        );
                                      }),
                                    );
                                    switch (result) {
                                      case "OK":
                                        {
                                          saveStore.saveChoiceImage(
                                              illust, indexs);
                                        }
                                    }
                                  },
                                )
                              : Container(),
                          ListTile(
                            leading: Icon(Icons.save_alt),
                            onTap: () async {
                              Navigator.of(context).pop();
                              saveStore.saveImage(illust, index: index - 1);
                            },
                            title: Text(I18n.of(context).Save),
                          ),
                          ListTile(
                            leading: Icon(Icons.cancel),
                            onTap: () => Navigator.of(context).pop(),
                            title: Text(I18n.of(context).Cancel),
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
                  illusts: illust,
                );
              }));
            },
            child: illust.metaPages.isEmpty
                ? Hero(
                    child: PixivImage(
                      illust.imageUrls.large,
                      placeHolder: illust.imageUrls.medium,
                    ),
                    tag: '${illust.imageUrls.medium}${widget.heroString}',
                  )
                : _buildIllustsItem(index - 1, illust),
          );
        });
  }

  Widget colorText(String text) => SelectableText(
        text,
        style: TextStyle(color: Theme.of(context).accentColor),
      );

  Widget _buildDetail(BuildContext context, Illusts illust) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _buildNameAvatar(context, illust),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text(I18n.of(context).Illust_id),
                      Container(
                        width: 10.0,
                      ),
                      colorText(illust.id.toString()),
                      Container(
                        width: 20.0,
                      ),
                      Text(I18n.of(context).Pixel),
                      Container(
                        width: 10.0,
                      ),
                      colorText("${illust.width}x${illust.height}")
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text(I18n.of(context).Total_view),
                      Container(
                        width: 10.0,
                      ),
                      colorText(illust.totalView.toString()),
                      Container(
                        width: 20.0,
                      ),
                      Text(I18n.of(context).Total_bookmark),
                      Container(
                        width: 10.0,
                      ),
                      colorText("${illust.totalBookmarks}")
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Wrap(
                spacing: 2, // gap between adjacent chips
                runSpacing: 0, // gap between lines
                children: illust.tags
                    .map((f) => Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                      MaterialPageRoute(builder: (context) {
                                    return ResultPage(
                                      word: f.name,
                                      translatedName: f.translatedName ?? '',
                                    );
                                  }));
                                },
                                onLongPress: () async {
                                  switch (await showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title:
                                              Text(I18n.of(context).Ban + "?"),
                                          actions: <Widget>[
                                            FlatButton(
                                              onPressed: () {
                                                Navigator.pop(context, "OK");
                                              },
                                              child: Text(I18n.of(context).OK),
                                            ),
                                            FlatButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child:
                                                  Text(I18n.of(context).Cancel),
                                            )
                                          ],
                                        );
                                      })) {
                                    case "OK":
                                      {
                                        BlocProvider.of<MuteBloc>(context).add(
                                            InsertBanTagEvent(f.name,
                                                f.translatedName ?? "_"));
                                      }
                                      break;
                                  }
                                },
                                child: Text(
                                  "#${f.name}",
                                  style: TextStyle(
                                      fontSize: 14.0,
                                      color: Theme.of(context).accentColor),
                                ),
                              ),
                              Container(
                                width: 10.0,
                              ),
                              Flexible(
                                  child: Text(
                                f.translatedName ?? "~",
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                softWrap: true,
                                style: Theme.of(context).textTheme.caption,
                              ))
                            ]))
                    .toList(),
              ),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SelectableHtml(
                  data: illust.caption.isEmpty ? "~" : illust.caption,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FlatButton(
                child: Text(
                  I18n.of(context).View_Comment,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: Theme.of(context).textTheme.bodyText1.fontSize),
                ),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) => CommentPage(
                            id: widget.id,
                          )));
                },
              ),
            )
          ],
        ),
      );

  Widget _buildNameAvatar(BuildContext context, Illusts illust) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Padding(
            child: GestureDetector(
              onLongPress: () {
                BlocProvider.of<IllustBloc>(context)
                    .add(FollowUserIllustEvent());
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
                                  color: illust.user.isFollowed
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
                  toShortTime(illust.createDate),
                  style: Theme.of(context).textTheme.caption,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
