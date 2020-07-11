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
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/component/star_icon.dart';
import 'package:pixez/main.dart';
import 'package:pixez/page/picture/illust_page.dart';
import 'package:pixez/page/picture/illust_store.dart';
import 'package:pixez/page/picture/picture_list_page.dart';

class IllustCard extends StatefulWidget {
  final IllustStore store;
  final List<IllustStore> iStores;
  bool needToBan;
  IllustCard({
    @required this.store,
    this.iStores,
    this.needToBan = false,
  });

  @override
  _IllustCardState createState() => _IllustCardState();
}

class _IllustCardState extends State<IllustCard> {
  IllustStore illustStore;
  Widget cardText() {
    if (illustStore.illusts.type != "illust") {
      return Text(
        illustStore.illusts.type,
        style: TextStyle(color: Colors.white),
      );
    }
    if (illustStore.illusts.metaPages.isNotEmpty) {
      return Text(
        illustStore.illusts.metaPages.length.toString(),
        style: TextStyle(color: Colors.white),
      );
    }
  }

  @override
  void initState() {
    illustStore = widget.store;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      if (userSetting.hIsNotAllow)
        for (int i = 0; i < illustStore.illusts.tags.length; i++) {
          if (illustStore.illusts.tags[i].name.startsWith('R-18'))
            return InkWell(
              onTap: () => {
                Navigator.of(context, rootNavigator: true)
                    .push(MaterialPageRoute(builder: (_) {
                  if (widget.store != null) {
                    return PictureListPage(
                      iStores: widget.iStores,
                      store: widget.store,
                    );
                  }
                  return IllustPage(
                    store: illustStore,
                    id: illustStore.illusts.id,
                  );
                }))
              },
              onLongPress: () {
                saveStore.saveImage(illustStore.illusts);
              },
              child: Card(
                margin: EdgeInsets.all(8.0),
                elevation: 8.0,
                clipBehavior: Clip.antiAlias,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8.0))),
                child: Image.asset('assets/h.jpg'),
              ),
            );
        }
      for (var i in muteStore.banillusts) {
        if (i.illustId == illustStore.illusts.id.toString())
          return Visibility(
            visible: false,
            child: Container(),
          );
      }
      for (var j in muteStore.banUserIds) {
        if (j.userId == illustStore.illusts.user.id.toString())
          return Visibility(
            visible: false,
            child: Container(),
          );
      }
      for (var t in muteStore.banTags) {
        for (var f in illustStore.illusts.tags) {
          if (f.name == t.name)
            return Visibility(
              visible: false,
              child: Container(),
            );
        }
      }
      return buildInkWell(context);
    });
  }

  String heroString =
      DateTime.now().millisecondsSinceEpoch.toString(); //两个作品可能出现在相邻页，用时间保证唯一herotag
  Widget buildInkWell(BuildContext context) {
    return InkWell(
      onTap: () => {
        Navigator.of(context, rootNavigator: true)
            .push(MaterialPageRoute(builder: (_) {
          if (widget.iStores != null) {
            return PictureListPage(
              heroString: heroString,
              store: widget.store,
              iStores: widget.iStores,
            );
          }
          return IllustPage(
            id: illustStore.illusts.id,
            heroString: heroString,
            store: illustStore,
          );
        }))
      },
      onLongPress: () {
        saveStore.saveImage(illustStore.illusts);
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
                child: (illustStore.illusts.height.toDouble() /
                            illustStore.illusts.width.toDouble()) >
                        2
                    ? Hero(
                        tag:
                            '${illustStore.illusts.imageUrls.medium}${heroString}',
                        child: CachedNetworkImage(
                          imageUrl: illustStore.illusts.imageUrls.squareMedium,
                          placeholder: (context, url) => Container(
                            height: 150,
                          ),
                          httpHeaders: {
                            "referer": "https://app-api.pixiv.net/",
                            "User-Agent": "PixivIOSApp/5.8.0"
                          },
                          // width: illustStore.illusts.width.toDouble(),
                          // fit: BoxFit.fitWidth,
                        ),
                      )
                    : Hero(
                        tag:
                            '${illustStore.illusts.imageUrls.medium}${heroString}',
                        child: CachedNetworkImage(
                          imageUrl: illustStore.illusts.imageUrls.medium,
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
                  height: 48,
                  child: Stack(
                    children: <Widget>[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 8.0, right: 34.0, top: 4, bottom: 4),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  illustStore.illusts.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.clip,
                                  style: Theme.of(context).textTheme.bodyText2,
                                ),
                                Text(
                                  illustStore.illusts.user.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.clip,
                                  style: Theme.of(context).textTheme.caption,
                                )
                              ]),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: StarIcon(
                          illustStore: illustStore,
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Align(
                child: _buildVisibility(),
                alignment: Alignment.topRight,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVisibility() {
    return Visibility(
      visible: illustStore.illusts.type != "illust" ||
          illustStore.illusts.metaPages.isNotEmpty,
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
