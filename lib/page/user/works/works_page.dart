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
import 'package:pixez/generated/l10n.dart';
import 'package:pixez/lighting/lighting_page.dart';
import 'package:pixez/lighting/lighting_store.dart';
import 'package:pixez/network/api_client.dart';

class WorksPage extends StatefulWidget {
  final int id;
  final ScrollController scrollController;
  const WorksPage({Key key, @required this.id, this.scrollController})
      : super(key: key);

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
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        _buildHeader(),
        Expanded(
          child: LightingList(
            source: futureGet,
            // scrollController: widget.scrollController,
          ),
        )
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
        child: Wrap(
          spacing: 8.0,
          alignment: WrapAlignment.center,
          children: <Widget>[
            ActionChip(
              backgroundColor: now == 'illust'
                  ? Theme.of(context).accentColor
                  : Colors.transparent,
              label: Text(
                I18n.of(context).Illust,
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
                I18n.of(context).Manga,
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
