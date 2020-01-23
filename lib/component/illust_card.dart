import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixez/bloc/bloc.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/component/star_icon.dart';
import 'package:pixez/models/illust.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/picture/picture_page.dart';

class IllustCard extends StatefulWidget {
  Illusts _illusts;

  IllustCard(this._illusts);

  @override
  _IllustCardState createState() => _IllustCardState();
}

class _IllustCardState extends State<IllustCard> {
  Widget cardText() {
    if (widget._illusts.type != "illust") {
      return Text(
        widget._illusts.type,
      );
    }
    if (widget._illusts.metaPages.isNotEmpty) {
      return Text(widget._illusts.metaPages.length.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MuteBloc, MuteState>(builder: (context, snapshot) {
      if (snapshot is DataMuteState) {
        for (var i in snapshot.banIllustIds) {
          if (i.illustId == widget._illusts.id.toString())
            return Visibility(
              visible: false,
              child: Container(),
            );
        }
        for (var j in snapshot.banUserIds) {
          if (j.userId == widget._illusts.user.id.toString())
            return Visibility(
              visible: false,
              child: Container(),
            );
        }
        for (var t in snapshot.banTags) {
          for (var f in widget._illusts.tags) {
            if (f.name == t.name)
              return Visibility(
                visible: false,
                child: Container(),
              );
          }
        }
      }
      return buildInkWell(context);
    });
  }

  Widget buildInkWell(BuildContext context) => InkWell(
        onTap: () => {
          Navigator.of(context, rootNavigator: true)
              .push(MaterialPageRoute(builder: (_) {
            return PicturePage(widget._illusts, widget._illusts.id);
          }))
        },
        onLongPress: () {
          if (widget._illusts.metaPages.isNotEmpty) {
            List<bool> indexs = List(widget._illusts.metaPages.length);
            for (int i = 0; i < widget._illusts.metaPages.length; i++) {
              indexs[i] = true;
            }
            BlocProvider.of<SaveBloc>(context)
                .add(SaveChoiceImageEvent(widget._illusts, indexs));
          } else
            BlocProvider.of<SaveBloc>(context)
                .add(SaveChoiceImageEvent(widget._illusts, [true]));
        },
        child: Card(
          margin: EdgeInsets.all(8.0),
          elevation: 8.0,
          clipBehavior: Clip.antiAlias,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0))),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Hero(
                child: Stack(
                  children: <Widget>[
                    PixivImage(widget._illusts.imageUrls.medium),
                    Visibility(
                      visible: widget._illusts.type != "illust" ||
                          widget._illusts.metaPages.isNotEmpty,
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Container(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 2.0, horizontal: 2.0),
                              child: cardText(),
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black26,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(4.0)),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                tag: widget._illusts.imageUrls.medium,
              ),
              ListTile(
                title: Text(
                  widget._illusts.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  widget._illusts.user.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: IconButton(
                    icon: StarIcon(widget._illusts.isBookmarked),
                    onPressed: () async {
                      final ApiClient client =
                          RepositoryProvider.of<ApiClient>(context);
                      try {
                        if (widget._illusts.isBookmarked) {
                          Response response =
                              await client.postUnLikeIllust(widget._illusts.id);
                        } else {
                          Response response = await client.postLikeIllust(
                              widget._illusts.id, "public", null);
                        }
                        setState(() {
                          widget._illusts.isBookmarked =
                              !widget._illusts.isBookmarked;
                        });
                      } catch (e) {} //懒得用bloc了
                    }),
              )
            ],
          ),
        ),
      );
}
