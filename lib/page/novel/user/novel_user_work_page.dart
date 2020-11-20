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
import 'package:pixez/lighting/lighting_store.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/novel/component/novel_lighting_list.dart';

class NovelUserWorkPage extends StatefulWidget {
  final int id;

  const NovelUserWorkPage({Key key, @required this.id}) : super(key: key);
  @override
  _NovelUserWorkPageState createState() => _NovelUserWorkPageState();
}

class _NovelUserWorkPageState extends State<NovelUserWorkPage> {
  FutureGet futureGet;
  @override
  void initState() {
    futureGet = () => apiClient.getUserNovels(widget.id);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: NovelLightingList(
            futureGet: futureGet,
          ),
        )
      ],
    );
  }
}
