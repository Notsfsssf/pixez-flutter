import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:pixez/bloc/save_bloc.dart';
import 'package:pixez/bloc/save_event.dart';
import 'package:pixez/bloc/save_state.dart';
import 'package:pixez/component/painter_avatar.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/component/transport_appbar.dart';
import 'package:pixez/generated/i18n.dart';
import 'package:pixez/models/illust.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/picture/bloc/bloc.dart';
import 'package:pixez/page/search/result/search_result_page.dart';
import 'package:pixez/page/user/bookmark/bloc.dart';
import 'package:share/share.dart';

abstract class ListItem {}

class IllustsItem implements ListItem {}

class DetailItem implements ListItem {}

class PicturePage extends StatefulWidget {
  final Illusts _illusts;

  PicturePage(this._illusts);

  @override
  _PicturePageState createState() => _PicturePageState();
}

class _PicturePageState extends State<PicturePage> {
  _showBookMarkDetailDialog(BuildContext context, BookmarkDetailState state) {
    showDialog(
        context: context,
        child: StatefulBuilder(
          builder: (BuildContext context, setBookState) {
            if (state is DataBookmarkDetailState) {
              final tags = state.bookMarkDetailResponse.bookmarkDetail.tags;
              final detail = state.bookMarkDetailResponse.bookmarkDetail;
              return AlertDialog(
                contentPadding: EdgeInsets.all(2.0),
                content: Container(
                  width: double.maxFinite,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text("1"),
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
                     Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: <Widget>[
                         Text((detail.restrict == "public"?I18n.of(context).Public:I18n.of(context).Private)+I18n.of(context).BookMark),
                        Switch(
                        onChanged: (bool value) {
                          setBookState(() {
                            detail.restrict = value ? "public" : "private";
                          });
                        },
                        value: detail.restrict == "public",
                      )
                     ],)
                    ],
                  ),
                ),
                actions: <Widget>[
                  FlatButton(
                    child: Text("Ok"),
                    onPressed: () {
                      Navigator.of(context).pop();
                      
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
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider<PictureBloc>(
            create: (context) => PictureBloc(ApiClient()),
          ),
          BlocProvider<BookmarkDetailBloc>(
            create: (BuildContext context) => BookmarkDetailBloc(ApiClient()),
          )
        ],
        child:
            BlocBuilder<PictureBloc, PictureState>(builder: (context, state) {
          return Scaffold(
            body: MultiBlocListener(
              listeners: [
                BlocListener<SaveBloc, SaveState>(
                  listener: (BuildContext context, SaveState state) {
                    if (state is SaveSuccesState) {
                      if (state.isNotSave)
                        Scaffold.of(context).showSnackBar(SnackBar(
                          content: Text(I18n.of(context).Saved),
                        ));
                    }
                  },
                ),
                BlocListener<BookmarkDetailBloc, BookmarkDetailState>(
                  listener: (BuildContext context, BookmarkDetailState state) {
                    if (state is DataBookmarkDetailState)
                      _showBookMarkDetailDialog(context, state);
                  },
                )
              ],
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  _buildList(widget._illusts),
                  TransportAppBar(
                    actions: <Widget>[
                      IconButton(
                          icon: Icon(Icons.more_vert),
                          onPressed: () {
                            buildShowModalBottomSheet(context, widget._illusts);
                          })
                    ],
                  )
                ],
              ),
            ),
            floatingActionButton: InkWell(
              splashColor: Colors.blue,
              onLongPress: () {
                BlocProvider.of<BookmarkDetailBloc>(context)
                    .add(FetchBookmarkDetailEvent(widget._illusts.id));
              },
              onTap: () {
                (state is DataState)
                    ? BlocProvider.of<PictureBloc>(context)
                        .add(StarEvent(state.illusts))
                    : BlocProvider.of<PictureBloc>(context)
                        .add(StarEvent(widget._illusts));
              },
              child: (state is DataState)
                  ? FloatingActionButton(
                      onPressed: () {},
                      child: Icon(Icons.star),
                      foregroundColor: state.illusts.isBookmarked
                          ? Colors.red
                          : Colors.white)
                  : FloatingActionButton(
                      onPressed: () {},
                      child: Icon(Icons.star),
                      foregroundColor: widget._illusts.isBookmarked
                          ? Colors.red
                          : Colors.white),
            ),
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
                        : null,
                    ListTile(
                      title: Text(I18n.of(context).Share),
                      leading: Icon(Icons.share,
                          color: Theme.of(context).primaryColor),
                      onTap: () {
                        Navigator.of(context).pop();
                        Share.share(
                            "https://www.pixiv.net/artworks/${widget._illusts.id}");
                      },
                    ),
                  ],
                ),
                Column(
                  children: <Widget>[
                    Container(
                      height: 2.0,
                      color: Colors.grey,
                    ),
                    ListTile(
                      leading: Icon(Icons.cancel,
                          color: Theme.of(context).primaryColor),
                      title: Text(I18n.of(context).Cancel),
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                    )
                  ],
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

  Widget _buildGridView() => BlocProvider<IllustRelatedBloc>(
        child: BlocBuilder<IllustRelatedBloc, IllustRelatedState>(
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
                  return PixivImage(
                      snapshot.recommend.illusts[index].imageUrls.squareMedium);
                });
          else
            return Center(
              child: CircularProgressIndicator(),
            );
        }),
        create: (BuildContext context) => IllustRelatedBloc(ApiClient())
          ..add(FetchRelatedEvent(widget._illusts)),
      );

  Widget _buildList(Illusts illust) {
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
            return _buildGridView();
          }
          if (index == count) {
            return _buildDetail(context, illust);
          } else
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
                            )
                          ],
                        ),
                      );
                    });
              },
              onTap: () {},
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

  Widget colorText(String text) => Text(
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
                  data: illust.caption.isEmpty ? "~" : illust.caption,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                I18n.of(context).View_Comment,
                textAlign: TextAlign.center,
              ),
            )
          ],
        ),
      );
}
