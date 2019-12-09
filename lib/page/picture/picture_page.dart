import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:pixez/component/painter_avatar.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/component/transport_appbar.dart';
import 'package:pixez/generated/i18n.dart';
import 'package:pixez/models/illust.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/picture/bloc/bloc.dart';
import 'package:save_in_gallery/save_in_gallery.dart';
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
  @override
  Widget build(BuildContext context) {
    return BlocProvider<PictureBloc>(
        create: (context) => PictureBloc(ApiClient()),
        child:
            BlocBuilder<PictureBloc, PictureState>(
              builder: (context, state) {
          return Scaffold(
            body: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                _buildList(widget._illusts),
                TransportAppBar(
                  actions: <Widget>[
                    IconButton(
                        icon: Icon(Icons.more_vert),
                        onPressed: () {
                          buildShowModalBottomSheet(context);
                        })
                  ],
                )
              ],
            ),
            floatingActionButton: (state is DataState)
                ? FloatingActionButton(
                    onPressed: () {
                      BlocProvider.of<PictureBloc>(context)
                          .add(StarEvent(state.illusts));
                    },
                    child: Icon(Icons.star),
                    foregroundColor:
                        state.illusts.isBookmarked ? Colors.red : Colors.white)
                : FloatingActionButton(
                    onPressed: () {
                      BlocProvider.of<PictureBloc>(context)
                          .add(StarEvent(widget._illusts));
                    },
                    child: Icon(Icons.star),
                    foregroundColor: widget._illusts.isBookmarked
                        ? Colors.red
                        : Colors.white),
          );
        }));
  }

  Future buildShowModalBottomSheet(BuildContext context) {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
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
                    ListTile(
                      title: Text("多选保存"),
                      leading: Icon(
                        Icons.save,
                        color: Theme.of(context).primaryColor,
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    ListTile(
                      title: Text("分享"),
                      leading: Icon(Icons.share,
                          color: Theme.of(context).primaryColor),
                      onTap: () {
                        Share.share(
                            "https://www.pixiv.net/artworks/${widget._illusts.id}");
                        Navigator.of(context).pop();
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
                      title: Text("取消"),
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

  Widget _buildList(Illusts illust) {
    final count = illust.metaPages.isEmpty ? 1 : illust.metaPages.length;
    return ListView.builder(
        itemCount: count + 1,
        itemBuilder: (BuildContext context, int index) {
          if (index == count) {
            return _buildDetail(context, illust);
          } else
            return BlocListener<PictureBloc, PictureState>(
              listener: (context, state) {
                if (state is SaveSuccesState) {
                   Scaffold.of(context).showSnackBar(SnackBar(
                    content: Text(I18n.of(context).Saved),
                  ));
                }
              },
              child: GestureDetector(
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
                                  BlocProvider.of<PictureBloc>(context)
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
              ),
            );
        });
  }

  Widget _buildDetail(BuildContext context, Illusts illust) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
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
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Html(
                  data: illust.caption.isEmpty ? "~" : illust.caption,
                ),
              ),
            ),
            Wrap(
              spacing: 2, // gap between adjacent chips
              runSpacing: 0, // gap between lines
              children: illust.tags
                  .map((f) => ActionChip(
                        label: Text(f.name),
                        onPressed: () {},
                      ))
                  .toList(),
            )
          ],
        ),
      );
}
