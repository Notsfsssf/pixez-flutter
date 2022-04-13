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
import 'package:pixez/component/sort_group.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/lighting/lighting_page.dart';
import 'package:pixez/lighting/lighting_store.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/hello/new/illust/new_illust_page.dart';


class MaterialNewIllustPageState extends NewIllustPageStateBase {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        LightingList(
          source: futureGet,
          refreshController: refreshController,
          header: Container(
            height: 45.0,
          ),
          portal: "new",
        ),
        Align(
          alignment: Alignment.topCenter,
          child: Container(
            child: SortGroup(
              onChange: (index) {
                if (index == 0)
                  setState(() {
                    futureGet = ApiForceSource(
                        futureGet: (e) =>
                            apiClient.getFollowIllusts('all', force: e));
                  });
                if (index == 1)
                  setState(() {
                    futureGet = ApiForceSource(
                        futureGet: (e) =>
                            apiClient.getFollowIllusts('public', force: e));
                  });
                if (index == 2)
                  setState(() {
                    futureGet = ApiForceSource(
                        futureGet: (e) =>
                            apiClient.getFollowIllusts('private', force: e));
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
                                futureGet = ApiForceSource(
                                    futureGet: (e) => apiClient
                                        .getFollowIllusts('all', force: e));
                              });
                            },
                          ),
                          ListTile(
                            title: Text(I18n.of(context).public),
                            onTap: () {
                              Navigator.of(context).pop();
                              setState(() {
                                futureGet = ApiForceSource(
                                    futureGet: (e) => apiClient
                                        .getFollowIllusts('public', force: e));
                              });
                            },
                          ),
                          ListTile(
                            title: Text(I18n.of(context).private),
                            onTap: () {
                              Navigator.of(context).pop();
                              setState(() {
                                futureGet = ApiForceSource(
                                    futureGet: (e) => apiClient
                                        .getFollowIllusts('private', force: e));
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
