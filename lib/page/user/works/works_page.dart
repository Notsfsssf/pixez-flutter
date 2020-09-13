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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pixez/component/sort_group.dart';
import 'package:pixez/generated/l10n.dart';
import 'package:pixez/lighting/lighting_page.dart';
import 'package:pixez/lighting/lighting_store.dart';
import 'package:pixez/network/api_client.dart';

class WorksPage extends StatefulWidget {
  final int id;
  const WorksPage({Key key, @required this.id}) : super(key: key);

  @override
  _WorksPageState createState() => _WorksPageState();
}

class _WorksPageState extends State<WorksPage> {
  FutureGet futureGet;

  @override
  void initState() {
    futureGet = () => apiClient.getUserIllusts(widget.id, 'illust');
    super.initState();
  }

  String now = 'illust';

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        LightingList(
          isNested: true,
          source: futureGet,
          header: Container(
            height: 50,
          ),
        ),
        Align(
          child: _buildSortChip(),
          alignment: Alignment.topCenter,
        ),
      ],
    );
  }

  int _currentSelection = 0;
  Widget _buildSortChip() {
    return SortGroup(
      onChange: (index) {
        setState(() {
          now = index == 0 ? 'illust' : 'manga';
          futureGet = () => apiClient.getUserIllusts(widget.id, now);
        });
      },
      children: [
        I18n.of(context).illust,
        I18n.of(context).manga,
      ],
    );
  }

  Widget _buildSegment() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CupertinoSlidingSegmentedControl(
        groupValue: _currentSelection,
        children: <int, Widget>{
          0: Text(I18n.of(context).illust),
          1: Text(I18n.of(context).painter),
        },
        onValueChanged: (int index) {
          setState(() {
            _currentSelection = index;
          });
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
        child: Wrap(
          alignment: WrapAlignment.center,
          children: <Widget>[
            ActionChip(
              backgroundColor: now == 'illust'
                  ? Theme.of(context).accentColor
                  : Colors.white,
              label: Text(
                I18n.of(context).illust,
                style: TextStyle(
                    color: now == 'illust'
                        ? Colors.white
                        : Theme.of(context).textTheme.headline6.color),
              ),
              onPressed: () {
                setState(() {
                  futureGet =
                      () => apiClient.getUserIllusts(widget.id, 'illust');
                  now = 'illust';
                });
              },
            ),
            ActionChip(
              label: Text(
                I18n.of(context).manga,
                style: TextStyle(
                    color: now == 'manga'
                        ? Colors.white
                        : Theme.of(context).textTheme.headline6.color),
              ),
              onPressed: () {
                setState(() {
                  futureGet =
                      () => apiClient.getUserIllusts(widget.id, 'manga');
                  now = 'manga';
                });
              },
              backgroundColor: now != 'illust'
                  ? Theme.of(context).accentColor
                  : Colors.transparent,
            )
          ],
        ),
      ),
    );
  }
}
