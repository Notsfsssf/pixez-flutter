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

import 'package:flutter/widgets.dart';
import 'package:pixez/models/illust.dart';
import 'package:pixez/page/picture/illust_page.dart';

class PictureListPage extends StatefulWidget {
  final List<Illusts> illusts;
  final int nowPosition;
  final String heroString;

  const PictureListPage(
      {Key key,
      @required this.illusts,
      @required this.nowPosition,
      this.heroString})
      : super(key: key);

  @override
  _PictureListPageState createState() => _PictureListPageState();
}

class _PictureListPageState extends State<PictureListPage> {
  PageController _pageController;

  @override
  void initState() {
    _pageController = PageController(initialPage: widget.nowPosition);
    super.initState();
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _pageController,
      children: <Widget>[
        ...widget.illusts.map((f) => IllustPage(
              id: f.id,
              illusts: f,
              heroString: widget.heroString,
            ))
      ],
    );
  }
}
