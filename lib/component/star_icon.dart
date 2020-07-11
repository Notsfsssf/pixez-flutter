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

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:like_button/like_button.dart';
import 'package:pixez/generated/l10n.dart';
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

class _StarIconState extends State<StarIcon> {
  //造一个Future实现通知并满足返回类型
  Future<bool> starWithToast() async {
    bool result = await widget.illustStore.star();
    if (result != null) {
      if (result) {
        String toastString =
            '${widget.illustStore.illusts.title}${I18n.of(context).Bookmarked}';
        BotToast.showCustomText(
            onlyOne: true,
            duration: Duration(seconds: 1),
            toastBuilder: (textCancel) => Align(
                  alignment: Alignment(0, 0.8),
                  child: Card(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.favorite,
                            color: Colors.redAccent,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 8.0),
                          child: Text(toastString ?? ''),
                        )
                      ],
                    ),
                  ),
                ));
      } else {
        String toastString =
            '${widget.illustStore.illusts.title}${I18n.of(context).Not_Bookmarked}';
        BotToast.showCustomText(
            onlyOne: true,
            duration: Duration(seconds: 1),
            toastBuilder: (textCancel) => Align(
                  alignment: Alignment(0, 0.8),
                  child: Card(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.favorite_border,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 8.0),
                          child: Text(toastString ?? ''),
                        )
                      ],
                    ),
                  ),
                ));
      }
      return result;
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      child: LikeButton(
          size: 24,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          circleColor:
              CircleColor(start: Colors.transparent, end: Colors.red),
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
  }
}
