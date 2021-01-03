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
import 'package:pixez/er/lprinter.dart';
import 'package:pixez/page/picture/illust_lighting_page.dart';
import 'package:pixez/page/picture/illust_store.dart';

class PictureListPage extends StatefulWidget {
  final IllustStore store;
  final List<IllustStore> iStores;
  final String heroString;

  const PictureListPage(
      {Key key, @required this.store, @required this.iStores, this.heroString})
      : super(key: key);

  @override
  _PictureListPageState createState() => _PictureListPageState();
}

class _PictureListPageState extends State<PictureListPage> {
  PageController _pageController;
  int nowPosition;
  double screenWidth = 0;

  @override
  void initState() {
    nowPosition = widget.iStores.indexOf(widget.store);
    _pageController = PageController(initialPage: nowPosition);
    super.initState();
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width / 2;
    return GestureDetector(
      onHorizontalDragEnd: (DragEndDetails detail) {
        LPrinter.d(detail);
        if (detail.velocity.pixelsPerSecond.dx.abs() > screenWidth) {
          int result = nowPosition;
          if (detail.velocity.pixelsPerSecond.dx < 0)
            result++;
          else
            result--;
          _pageController.animateToPage(result,
              duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
          if (result >= widget.iStores.length)
            result = widget.iStores.length - 1;
          if (result < 0) result = 0;
          setState(() {
            nowPosition = result;
          });
        }
      },
      child: PageView.builder(
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          final f = widget.iStores[index];
          String tag = nowPosition == index ? widget.heroString : null;
          return IllustLightingPage(
            id: f.id,
            heroString: tag,
            store: f,
          );
        },
        itemCount: widget.iStores.length,
      ),
    );
  }
}
