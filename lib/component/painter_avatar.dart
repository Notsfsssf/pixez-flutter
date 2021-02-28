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
import 'package:flutter/widgets.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/page/user/users_page.dart';
import 'package:pixez/exts.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/main.dart';

class PainterAvatar extends StatefulWidget {
  final String url;
  final int id;
  final GestureTapCallback onTap;
  final Size size;

  const PainterAvatar({Key key, this.url, this.id, this.onTap, this.size})
      : super(key: key);

  @override
  _PainterAvatarState createState() => _PainterAvatarState();
}

class _PainterAvatarState extends State<PainterAvatar> {
  void pushToUserPage() {
    Navigator.of(context, rootNavigator: true)
        .push(MaterialPageRoute(builder: (_) {
      return UsersPage(id: widget.id);
    }));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          if (widget.onTap == null) {
            pushToUserPage();
          } else
            widget.onTap();
        },
        child: widget.size == null
            ? SizedBox(
                height: 60,
                width: 60,
                child: CircleAvatar(
                  backgroundImage: PixivProvider.url(widget.url.toTrueUrl()),
                  radius: 100.0,
                ),
              )
            : Container(
                height: widget.size.height,
                width: widget.size.width,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      image: PixivProvider.url(
                        widget.url.toTrueUrl(),
                        host: splashStore.host == ImageCatHost
                            ? ImageCatHost
                            : ImageHost,
                      ),
                      fit: BoxFit.cover),
                ),
              ));
  }
}
