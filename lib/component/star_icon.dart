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

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:like_button/like_button.dart';
import 'package:pixez/page/picture/illust_store.dart';

class StarIcon extends StatefulWidget {
  final IllustStore illustStore;
  const StarIcon({
    Key key,
    @required this.illustStore,
  }) : super(key: key);

  @override
  _StarIconState createState() => _StarIconState();
}

class _StarIconState extends State<StarIcon>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      return Container(
        width: 32,
        child: LikeButton(
          size: 26,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          padding: EdgeInsets.all(0.0),
          circleColor:
              CircleColor(start: Colors.transparent, end: Colors.redAccent),
          bubblesColor: BubblesColor(
            dotPrimaryColor: Colors.red,
            dotSecondaryColor: Colors.redAccent,
          ),
          isLiked: widget.illustStore.isBookmark,
          likeBuilder: (context) {
            return Icon(
              widget.illustStore.isBookmark
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: widget.illustStore.isBookmark ? Colors.red : Colors.grey,
            );
          },
          onTap: (v) {
            return widget.illustStore.star();
          },
        ),
      );
    });
  }
}
