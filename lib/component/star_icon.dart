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
  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      return Container(
        width: 36,
        height: 36,
        child: IconButton(
            padding: EdgeInsets.all(0.0),
            icon: _buildData(widget.illustStore.state),
            onPressed: () async {
              widget.illustStore.star();
            }),
      );
    });
  }

  Widget _buildData(int state) {
    switch (state) {
      case 0:
        return Icon(
          Icons.favorite_border,
          color: Colors.grey,
        );
        break;
      case 1:
        return Icon(Icons.favorite, color: Colors.grey);
        break;
      default:
        return Icon(
          Icons.favorite,
          color: Colors.red,
        );
        break;
    }
  }
}
