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
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/models/novel_recom_response.dart';

class NovelCard extends StatefulWidget {
  final int id;
  final Novel novel;

  const NovelCard({Key? key, required this.id, required this.novel})
      : super(key: key);

  @override
  _NovelCardState createState() => _NovelCardState();
}

class _NovelCardState extends State<NovelCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: <Widget>[
          Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              PixivImage(widget.novel.imageUrls.squareMedium),
              Text(widget.novel.totalView.toString())
            ],
          ),
          Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Text(widget.novel.title),
              Text('by ${widget.novel.user.name}'),
              Text(widget.novel.caption)
            ],
          )
        ],
      ),
    );
  }
}
