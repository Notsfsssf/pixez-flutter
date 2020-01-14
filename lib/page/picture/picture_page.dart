import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:pixez/bloc/illust_persist_bloc.dart';
import 'package:pixez/bloc/illust_persist_event.dart';
import 'package:pixez/bloc/save_bloc.dart';
import 'package:pixez/bloc/save_event.dart';
import 'package:pixez/bloc/save_state.dart';
import 'package:pixez/component/painter_avatar.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/component/star_icon.dart';
import 'package:pixez/component/transport_appbar.dart';
import 'package:pixez/component/ugoira_animation.dart';
import 'package:pixez/generated/i18n.dart';
import 'package:pixez/models/bookmark_detail.dart';
import 'package:pixez/models/illust.dart';
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
                      ListView.builder(
                        itemCount: tags.length,
                        shrinkWrap: true,
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
                                    state.bookMarkDetailResponse.bookmarkDetail
                                        .tags[index].isRegistered = value;
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

  @override
  Widget build(BuildContext context) {
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
          )
        ],
        child: BlocBuilder<PictureBloc, PictureState>(
            builder: (context, snapshot) {
          return Scaffold(
            body: BlocBuilder<IllustBloc, IllustState>(
                builder: (context, illustState) {
              if (illustState is DataIllustState) {
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
                  child: Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      _buildList(illustState.illusts, illustState),
                      TransportAppBar(
                        actions: <Widget>[
                          IconButton(
                              icon: Icon(Icons.more_vert),
                              onPressed: () {
                                buildShowModalBottomSheet(
                                    context, illustState.illusts);
                              })
                        ],
                      )
                    ],
                  ),
                );
              } else
                return Center(
                  child: CircularProgressIndicator(),
                );
            }),
            floatingActionButton: BlocBuilder<IllustBloc, IllustState>(
                builder: (context, illustState) {
              if (illustState is DataIllustState)
                return InkWell(
                    splashColor: Colors.blue,
                    onLongPress: () {
                      BlocProvider.of<BookmarkDetailBloc>(context).add(
                          FetchBookmarkDetailEvent(illustState.illusts.id));
                    },
                    onTap: () {},
                    child: (snapshot is DataState)
                        ? FloatingActionButton(
                            onPressed: () {
                              BlocProvider.of<PictureBloc>(context).add(
                                  StarPictureEvent(
                                      snapshot.illusts, "public", null));
                            },
                            backgroundColor: Colors.white,
                            child: StarIcon(snapshot.illusts.isBookmarked))
                        : FloatingActionButton(
                            onPressed: () {
                              BlocProvider.of<PictureBloc>(context).add(
                                  StarPictureEvent(
                                      illustState.illusts, "public", null));
                            },
                            backgroundColor: Colors.white,
                            child: StarIcon(illustState.illusts.isBookmarked),
                          ));
              return FloatingActionButton(
                onPressed: () {},
              );
            }),
          );
        }));
  }

  Future buildShowModalBottomSheet(BuildContext context, Illusts illusts) {
    return showModalBottomSheet(
        context: context,
        builder: (_) {
          return Container(
            color: Colors.white,
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
                              color: Theme.of(context).primaryColor,
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
                      leading: Icon(Icons.share,
                          color: Theme.of(context).primaryColor),
                      onTap: () {
                        Navigator.of(context).pop();

                        Share.share(
                            "https://www.pixiv.net/artworks/${widget.id}");
                      },
                    ),
                  ],
                ),
                ListTile(
                  leading:
                      Icon(Icons.cancel, color: Theme.of(context).primaryColor),
                  title: Text(I18n.of(context).Cancel),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
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
          placeHolder: illust.metaPages[index].imageUrls.medium,
        );

  Widget _buildGridView(DataIllustState illustState) =>
      BlocBuilder<IllustRelatedBloc, IllustRelatedState>(
          builder: (context, snapshot) {
        if (snapshot is DataIllustRelatedState)
          return GridView.builder(
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

  Widget _buildList(Illusts illust, DataIllustState illustState) {
    final count = illust.metaPages.isEmpty ? 1 : illust.metaPages.length;
    return ListView.builder(
        itemCount: count + 3,
        itemBuilder: (BuildContext context, int index) {
          if (index == count + 1) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(I18n.of(context).About_Picture),
                ),
              ],
            );
          }
          if (index == count + 2) {
            return _buildGridView(illustState);
          }
          if (index == count) {
            return _buildDetail(context, illust);
          }
          if (illust.type == "ugoira") {
            return BlocProvider<UgoiraMetadataBloc>(
              child: BlocBuilder<UgoiraMetadataBloc, UgoiraMetadataState>(
                  builder: (context, snapshot) {
                if (snapshot is DownLoadProgressState) {
                  return Center(
                    child: CircularProgressIndicator(
                      value: snapshot.count / snapshot.total,
                    ),
                  );
                }
                if (snapshot is PlayUgoiraMetadataState) {
                  return FrameAnimationImage(
                    snapshot.listSync,
                    interval: snapshot.frames.first.delay,
                  );
                  // return UgoiraAnima(snapshot.listSync,snapshot.frames);
                }
                return Stack(
                  children: <Widget>[
                    Hero(
                      child: PixivImage(
                        illust.imageUrls.large,
                        placeHolder: illust.imageUrls.medium,
                      ),
                      tag: illust.imageUrls.medium,
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: IconButton(
                        onPressed: () {
                          BlocProvider.of<UgoiraMetadataBloc>(context)
                              .add(FetchUgoiraMetadataEvent(illust.id));
                        },
                        icon: Icon(Icons.play_arrow),
                      ),
                    )
                  ],
                );
              }),
              create: (context) =>
                  UgoiraMetadataBloc(RepositoryProvider.of<ApiClient>(context)),
            );
          }

          return GestureDetector(
            onLongPress: () {
              showModalBottomSheet(
                  context: context,
                  builder: (_) {
                    return Container(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          ListTile(
                            leading: Icon(Icons.save_alt),
                            onTap: () async {
                              Navigator.of(context).pop();
                              BlocProvider.of<SaveBloc>(context)
                                  .add(SaveImageEvent(illust, index));
                            },
                            title: Text(I18n.of(context).Save),
                          ),
                          ListTile(
                            leading: Icon(Icons.cancel),
                            onTap: () => Navigator.of(context).pop(),
                            title: Text("Cancel"),
                          ),
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
                      : illust.metaPages[index].imageUrls.large,
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
                : _buildIllustsItem(index, illust),
          );
        });
  }

  Widget colorText(String text) => SelectableText(
        text,
        style: TextStyle(color: Theme.of(context).primaryColor),
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
                    child: PainterAvatar(
                      url: illust.user.profileImageUrls.medium,
                      id: illust.user.id,
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
                              TextStyle(color: Theme.of(context).primaryColor),
                        ),
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
                                child: Text(
                                  "#${f.name}",
                                  style: TextStyle(
                                      color: Theme.of(context).primaryColor),
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
                child: Html(
                  onLinkTap: (String url) {
                    Share.share(url);
                  },
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
