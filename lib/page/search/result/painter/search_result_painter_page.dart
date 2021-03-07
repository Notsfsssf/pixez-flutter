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
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/painter/painter_list.dart';

class SearchResultPainterPage extends StatefulWidget {
  final String word;

  SearchResultPainterPage({Key? key,required this.word}) : super(key: key);

  @override
  _SearchResultPainterPageState createState() =>
      _SearchResultPainterPageState();
}

class _SearchResultPainterPageState extends State<SearchResultPainterPage> {

  @override
  Widget build(BuildContext context) {
    return PainterList(futureGet: () => apiClient.getSearchUser(widget.word),);
  }
}
