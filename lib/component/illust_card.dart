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

import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/component/null_hero.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/component/star_icon.dart';
import 'package:pixez/main.dart';
import 'package:pixez/page/picture/illust_lighting_page.dart';
import 'package:pixez/page/picture/illust_store.dart';
import 'package:pixez/page/picture/picture_list_page.dart';

class IllustCard extends StatefulWidget {
  final IllustStore store;
  final List<IllustStore> iStores;
  final bool needToBan;
  final double height;

  IllustCard({
    @required this.store,
    this.iStores,
    this.needToBan = false,
    this.height,
  });

  @override
  _IllustCardState createState() => _IllustCardState();
}

class _IllustCardState extends State<IllustCard> {
  IllustStore store;
  List<IllustStore> iStores;
  String tag;

  @override
  void initState() {
    store = widget.store;
    iStores = widget.iStores;
    tag = this.hashCode.toString();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (userSetting.hIsNotAllow)
      for (int i = 0; i < store.illusts.tags.length; i++) {
        if (store.illusts.tags[i].name.startsWith('R-18'))
          return InkWell(
            onTap: () => _buildTap(context),
            onLongPress: () => saveStore.saveImage(store.illusts),
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
    if (widget.height != null)
      return Container(
        child: buildInkWell(context),
        height: widget.height,
      );
    return buildInkWell(context);
  }

  Future _buildTap(BuildContext context) {
    return Navigator.of(context, rootNavigator: true)
        .push(MaterialPageRoute(builder: (_) {
      if (store != null) {
        return PictureListPage(
          iStores: iStores,
          store: store,
          heroString: tag,
        );
      }
      return IllustLightingPage(
        store: store,
        id: store.illusts.id,
        heroString: tag,
      );
    }));
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

  Widget _buildPic(String tag) {
    return (store.illusts.height.toDouble() / store.illusts.width.toDouble()) >
            3
        ? NullHero(
            tag: tag,
            child: PixivImage(store.illusts.imageUrls.squareMedium,
                fit: BoxFit.fitWidth),
          )
        : NullHero(
            tag: tag,
            child: PixivImage(store.illusts.imageUrls.medium,
                fit: BoxFit.fitWidth),
          );
  }

  Widget buildInkWell(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      elevation: 4.0,
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0))),
      child: InkWell(
        onLongPress: () {
          saveStore.saveImage(store.illusts);
        },
        onTap: () {
          _buildInkTap(context, tag);
        },
        child: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.topCenter,
              child: _buildPic(tag),
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
    );
  }

  Future _buildInkTap(BuildContext context, String heroTag) {
    return Navigator.of(context, rootNavigator: true)
        .push(MaterialPageRoute(builder: (_) {
      if (iStores != null) {
        return PictureListPage(
          heroString: heroTag,
          store: store,
          iStores: iStores,
        );
      }
      return IllustLightingPage(
        id: store.illusts.id,
        heroString: heroTag,
        store: store,
      );
    }));
  }

  Widget _buildBottom(BuildContext context) {
    return Container(
      color: Theme.of(context).cardColor,
      height: 50,
      child: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(
                left: 8.0, right: 36.0, top: 4, bottom: 4),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                style: Theme.of(context).textTheme.caption,
              )
            ]),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: Observer(builder: (_) {
                return StarIcon(
                  state: store.state,
                );
              }),
              onPressed: () => store.star(),
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
