import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixez/bloc/bloc.dart';
import 'package:pixez/bloc/illust_persist_bloc.dart';
import 'package:pixez/bloc/illust_persist_event.dart';
import 'package:pixez/bloc/save_bloc.dart';
import 'package:pixez/bloc/save_event.dart';
import 'package:pixez/component/ban_page.dart';
import 'package:pixez/component/painter_avatar.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/component/selectable_html.dart';
import 'package:pixez/component/star_icon.dart';
import 'package:pixez/component/ugoira_animation.dart';
import 'package:pixez/generated/i18n.dart';
import 'package:pixez/models/bookmark_detail.dart';
import 'package:pixez/models/illust.dart';
import 'package:pixez/models/ugoira_metadata_response.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/comment/comment_page.dart';
import 'package:pixez/page/picture/bloc/bloc.dart';
import 'package:pixez/page/search/result/search_result_page.dart';
import 'package:pixez/page/zoom/zoom_page.dart';
import 'package:share/share.dart';

abstract class ListItem {}

class IllustsItem implements ListItem {}

class DetailItem implements ListItem {}

class PicturePage extends StatefulWidget {
  final Illusts _illusts;
  final int id;

  PicturePage(this._illusts, this.id);

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
                    mainAxisSize: MainAxisSize.min,
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
                      Container(
                        height: 400,
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

  @override
  void initState() {
    super.initState();
  }

  bool _playButtonVisible = true;

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
          for (var j in muteState.banUserIds) {
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
                    for (var j in muteState.banUserIds) {
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
                                child: Text('Encode'),
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
        context: context,
        builder: (_) {
          return Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
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
                                    BlocProvider.of<SaveBloc>(context).add(
                                        SaveChoiceImageEvent(illusts, indexs));
                                  }
                              }
                            },
                          )
                        : Container(),
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
                                content: Text(I18n.of(context).Report_Message),
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
          );
        });
  }

  Widget _buildIllustsItem(int index, Illusts illust) => index == 0
      ? Hero(
          child: PixivImage(
            illust.metaPages[index].imageUrls.large,
            placeHolder: illust.metaPages[index].imageUrls.medium,
          ),
          tag: illust.imageUrls.medium,
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

  Widget _buildList(context, Illusts illust, DataIllustState illustState) {
    final count = illust.metaPages.isEmpty ? 1 : illust.metaPages.length;
    return ListView.builder(
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
                return InkWell(
                  onLongPress: () {
                    /*                BlocProvider.of<UgoiraMetadataBloc>(context)
                        .add(EncodeToGifEvent());*/
                  },
                  child: FrameAnimationImage(
                    snapshot.listSync,
                    interval: frames.first.delay,
                    illusts: illust,
                  ),
                );
                // return UgoiraAnima(snapshot.listSync,snapshot.frames);
              }
              return Hero(
                child: PixivImage(
                  illust.imageUrls.large,
                  placeHolder: illust.imageUrls.medium,
                ),
                tag: illust.imageUrls.medium,
              );
            });
          }
          return GestureDetector(
            onLongPress: () {
              showModalBottomSheet(
                  context: context,
                  builder: (c1) {
                    return Container(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          ListTile(
                            leading: Icon(Icons.save_alt),
                            onTap: () async {
                              Navigator.of(context).pop();
                              BlocProvider.of<SaveBloc>(context)
                                  .add(SaveImageEvent(illust, index - 1));
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
                return ZoomPage(
                  url: illust.metaPages.isEmpty
                      ? illust.imageUrls.large
                      : illust.metaPages[index - 1].imageUrls.large,
                );
              }));
            },
            child: illust.metaPages.isEmpty
                ? Hero(
              child: PixivImage(
                illust.imageUrls.large,
                placeHolder: illust.imageUrls.medium,
              ),
              tag: illust.imageUrls.medium,
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
            Row(
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
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: illust.user.isFollowed
                                        ? Colors.yellow
                                        : Theme.of(context).accentColor,
                                  ),
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
                        Text(
                          illust.title,
                          style:
                              TextStyle(color: Theme.of(context).accentColor),
                        ),
                        Container(height: 4.0,),
                        Text(illust.user.name),
                        Text(illust.createDate),
                      ],
                    ),
                  ),
                ),
              ],
            ),
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
                                    return SearchResultPage(
                                      word: f.name,
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
}
