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
import 'package:pixez/page/about/thanks_peoples.dart';

class ThanksList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        ListTile(
          title: Text(
              '    一路做到现在的flutter版也过了好久了，虽然多次下架，版本包名甚至名称多次变更，但是在这些时间里，我得到了很多人的帮助，支持与鼓励，积累了许多开发经验还有社会教训，还能够有机会与想法出色、技术出众、审美出彩的用户、开发者、设计师交流，还可以顺便安利自己喜欢的歌曲，真是太棒了，非常感谢你们的支持:'),
        ),
        Divider(),
        ...peoples.map((e) => ListTile(
              title: Text(e),
            )),
      ],
    );
  }
}
