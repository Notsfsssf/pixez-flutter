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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/component/star_icon.dart';
import 'package:pixez/main.dart';
import 'package:pixez/page/picture/illust_page.dart';
import 'package:pixez/page/picture/illust_store.dart';
import 'package:pixez/page/picture/picture_list_page.dart';

class IllustCard extends StatelessWidget {
  final IllustStore store;
  final List<IllustStore> iStores;
  final bool needToBan;
  final double height;
  final String heroString;

  IllustCard({
    @required this.store,
    this.iStores,
    this.needToBan = false,
    this.height,
    this.heroString,
  });

  @override
  Widget build(BuildContext context) {
    if (userSetting.hIsNotAllow)
      for (int i = 0; i < store.illusts.tags.length; i++) {
        if (store.illusts.tags[i].name.startsWith('R-18'))
          return InkWell(
            onTap: () => {
              Navigator.of(context, rootNavigator: true)
                  .push(MaterialPageRoute(builder: (_) {
                if (store != null) {
                  return PictureListPage(
                    iStores: iStores,
                    store: store,
                  );
                }
                return IllustPage(
                  store: store,
                  id: store.illusts.id,
                );
              }))
            },
            onLongPress: () {
              saveStore.saveImage(store.illusts);
            },
            child: Card(
              margin: EdgeInsets.all(8.0),
              elevation: 8.0,
              clipBehavior: Clip.antiAlias,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8.0))),
              child: Image.asset('assets/images/h.jpg'),
            ),
          );
      }
    if (height != null)
      return Container(
        child: buildInkWell(context),
        height: height,
      );
    return buildInkWell(context);
  }

  Widget cardText() {
    if (store.illusts.type != "illust") {
      return Text(
        store.illusts.type,
        style: TextStyle(color: Colors.white),
      );
    }
    if (store.illusts.metaPages.isNotEmpty) {
      return Text(
        store.illusts.metaPages.length.toString(),
        style: TextStyle(color: Colors.white),
      );
    }
    return Text('');
  }

  Widget _buildPic(String heroString) {
    return (store.illusts.height.toDouble() / store.illusts.width.toDouble()) >
            3
        ? Hero(
            tag: '${store.illusts.imageUrls.medium}$heroString',
            child: PixivImage(
              store.illusts.imageUrls.squareMedium,
            ),
          )
        : Hero(
            tag: '${store.illusts.imageUrls.medium}$heroString',
            child: PixivImage(
              store.illusts.imageUrls.medium,
            ),
          );
  }

  Widget buildInkWell(BuildContext context) {
    String heroString =
        this.heroString ?? DateTime.now().millisecondsSinceEpoch.toString();
    return InkWell(
      onTap: () => {
        Navigator.of(context, rootNavigator: true)
            .push(MaterialPageRoute(builder: (_) {
          if (iStores != null) {
            return PictureListPage(
              heroString: heroString,
              store: store,
              iStores: iStores,
            );
          }
          return IllustPage(
            id: store.illusts.id,
            heroString: heroString,
            store: store,
          );
        }))
      },
      onLongPress: () {
        saveStore.saveImage(store.illusts);
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
                child: _buildPic(heroString),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: _buildBottom(context),
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

  Widget _buildBottom(BuildContext context) {
    return Container(
      color: Theme.of(context).cardColor,
      height: 50,
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 8.0, right: 34.0, top: 4, bottom: 4),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      store.illusts.title,
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                      style: Theme.of(context).textTheme.bodyText2,
                    ),
                    Text(
                      store.illusts.user.name,
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                      style: Theme
                          .of(context)
                          .textTheme
                          .caption,
                    )
                  ]),
            ),
          ),
          Expanded(
            flex: 1,
            child: StarIcon(
              illustStore: store,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildVisibility() {
    return Visibility(
      visible:
          store.illusts.type != "illust" || store.illusts.metaPages.isNotEmpty,
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
