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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pixez/component/sort_group.dart';
import 'package:pixez/generated/l10n.dart';
import 'package:pixez/lighting/lighting_page.dart';
import 'package:pixez/lighting/lighting_store.dart';
import 'package:pixez/main.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class NewIllustPage extends StatefulWidget {
  final String restrict;

  const NewIllustPage({Key? key, this.restrict = "all"}) : super(key: key);

  @override
  _NewIllustPageState createState() => _NewIllustPageState();
}

class _NewIllustPageState extends State<NewIllustPage> {
  late FutureGet futureGet;
  late RefreshController _refreshController;
  late StreamSubscription<String> subscription;

  @override
  void initState() {
    _refreshController = RefreshController();
    futureGet = () => apiClient.getFollowIllusts(widget.restrict);
    super.initState();
    subscription = topStore.topStream.listen((event) {
      if (event == "301") {
        _refreshController?.position?.jumpTo(0);
      }
    });
  }

  @override
  void dispose() {
    subscription?.cancel();
    _refreshController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        LightingList(
          source: futureGet,
          refreshController: _refreshController,
          header: Container(
            height: 45.0,
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: Container(
            child: SortGroup(
              onChange: (index) {
                if (index == 0)
                  setState(() {
                    futureGet = () => apiClient.getFollowIllusts('all');
                  });
                if (index == 1)
                  setState(() {
                    futureGet = () => apiClient.getFollowIllusts('public');
                  });
                if (index == 2)
                  setState(() {
                    futureGet = () => apiClient.getFollowIllusts('private');
                  });
              },
              children: [
                I18n.of(context).all,
                I18n.of(context).public,
                I18n.of(context).private
              ],
            ),
          ),
        )
      ],
    );
  }

  Container buildContainer(BuildContext context) {
    return Container(
        child: Align(
      alignment: Alignment.centerRight,
      child: IconButton(
          icon: Icon(Icons.list),
          onPressed: () {
            showModalBottomSheet(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                context: context,
                builder: (context) => SafeArea(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          ListTile(
                            title: Text(I18n.of(context).all),
                            onTap: () {
                              Navigator.of(context).pop();
                              setState(() {
                                futureGet =
                                    () => apiClient.getFollowIllusts('all');
                              });
                            },
                          ),
                          ListTile(
                            title: Text(I18n.of(context).public),
                            onTap: () {
                              Navigator.of(context).pop();
                              setState(() {
                                futureGet =
                                    () => apiClient.getFollowIllusts('public');
                              });
                            },
                          ),
                          ListTile(
                            title: Text(I18n.of(context).private),
                            onTap: () {
                              Navigator.of(context).pop();
                              setState(() {
                                futureGet =
                                    () => apiClient.getFollowIllusts('private');
                              });
                            },
                          ),
                        ],
                      ),
                    ));
          }),
    ));
  }
}
