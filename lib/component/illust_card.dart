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

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixez/bloc/bloc.dart';
import 'package:pixez/component/star_icon.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/illust.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/picture/picture_list_page.dart';
import 'package:pixez/page/picture/picture_page.dart';

class IllustCard extends StatefulWidget {
  Illusts _illusts;
  final List<Illusts> illustList;

  IllustCard(this._illusts, {this.illustList});

  @override
  _IllustCardState createState() => _IllustCardState();
}

class _IllustCardState extends State<IllustCard> {
  Widget cardText() {
    if (widget._illusts.type != "illust") {
      return Text(
        widget._illusts.type,
        style: TextStyle(color: Colors.white),
      );
    }
    if (widget._illusts.metaPages.isNotEmpty) {
      return Text(
        widget._illusts.metaPages.length.toString(),
        style: TextStyle(color: Colors.white),
      );
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

  Widget buildInkWell(BuildContext context) {
    double screanWidth = MediaQuery.of(context).size.width;
    double itemWidth = (screanWidth / 2.0) - 32.0;
    double radio =
        widget._illusts.height.toDouble() / widget._illusts.width.toDouble();
    double mainAxisExtent = 80.0;
    if (radio > 2)
      mainAxisExtent += itemWidth;
    else
      mainAxisExtent += itemWidth * radio;

    String heroString = DateTime.now().millisecondsSinceEpoch.toString();
    return InkWell(
      onTap: () => {
        Navigator.of(context, rootNavigator: true)
            .push(MaterialPageRoute(builder: (_) {
          if (widget.illustList != null) {
            return PictureListPage(
              illusts: widget.illustList,
              nowPosition: widget.illustList.indexOf(widget._illusts),
              heroString: heroString,
            );
          }
          return PicturePage(
            widget._illusts,
            widget._illusts.id,
            heroString: heroString,
          );
        }))
      },
      onLongPress: () {
        saveStore.saveImage(widget._illusts);
      },
      child: Card(
        margin: EdgeInsets.all(8.0),
        elevation: 8.0,
        clipBehavior: Clip.antiAlias,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0))),
        child: Container(
          child: Stack(
            children: <Widget>[
              Align(
                alignment: Alignment.topCenter,
                child: (widget._illusts.height.toDouble() /
                            widget._illusts.width.toDouble()) >
                        2
                    ? Hero(
                        tag: '${widget._illusts.imageUrls.medium}${heroString}',
                        child: CachedNetworkImage(
                          imageUrl: widget._illusts.imageUrls.squareMedium,
                          placeholder: (context, url) => Container(
                            height: 150,
                          ),
                          httpHeaders: {
                            "referer": "https://app-api.pixiv.net/",
                            "User-Agent": "PixivIOSApp/5.8.0"
                          },
                          width: widget._illusts.width.toDouble(),
                          // fit: BoxFit.fitWidth,
                        ),
                      )
                    : Hero(
                        tag: '${widget._illusts.imageUrls.medium}${heroString}',
                        child: CachedNetworkImage(
                          imageUrl: widget._illusts.imageUrls.medium,
                          placeholder: (context, url) => Container(
                            height: 150,
                          ),
                          httpHeaders: {
                            "referer": "https://app-api.pixiv.net/",
                            "User-Agent": "PixivIOSApp/5.8.0"
                          },
                          // fit: BoxFit.fitWidth,
                        ),
                      ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  color: Theme.of(context).cardColor,
                  height: 46,
                  child: Stack(
                    children: <Widget>[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 8.0, right: 34.0, top: 4),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget._illusts.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.clip,
                                  style: Theme.of(context).textTheme.bodyText2,
                                ),
                                Text(
                                  widget._illusts.user.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.clip,
                                  style: Theme.of(context).textTheme.caption,
                                )
                              ]),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                            icon: StarIcon(widget._illusts.isBookmarked),
                            onPressed: () async {
                              final ApiClient client =
                                  RepositoryProvider.of<ApiClient>(context);
                              try {
                                if (widget._illusts.isBookmarked) {
                                  Response response = await client
                                      .postUnLikeIllust(widget._illusts.id);
                                } else {
                                  Response response =
                                      await client.postLikeIllust(
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
              ),
              Align(child: _buildVisibility(),alignment: Alignment.topRight,)
            ],
          ),
        ),
      ),
    );
  }

  Visibility _buildVisibility() {
    return Visibility(
      visible: widget._illusts.type != "illust" ||
          widget._illusts.metaPages.isNotEmpty,
      child: Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: EdgeInsets.all(4.0),
          child: Container(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 2.0, horizontal: 2.0),
              child: cardText(),
            ),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.all(Radius.circular(4.0)),
            ),
          ),
        ),
      ),
    );
  }
}
