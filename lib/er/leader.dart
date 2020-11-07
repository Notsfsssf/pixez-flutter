/*
 * Copyright (C) 2020. by perol_notsf, All rights reserved
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful, but WITHOUT ANY
 *  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 *  FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License along with
 *  this program. If not, see <http://www.gnu.org/licenses/>.
 */

//有是有top level fun和extension，奈何auto import 太傻，还是这种更稳一些
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Leader {
  static pushWithScaffold(context, Widget widget) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => Scaffold(
              body: widget,
            )));
  }

  static push(context, Widget widget) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => Scaffold(
              body: widget,
            )));
  }
}
