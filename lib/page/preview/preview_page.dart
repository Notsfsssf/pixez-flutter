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
import 'package:pixez/component/painter_avatar.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/constants.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/lighting/lighting_store.dart';
import 'package:pixez/models/illust.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/login/login_page.dart';
import 'package:pixez/page/preview/fluent_preview_state.dart';
import 'package:pixez/page/preview/material_preview_state.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class GoToLoginPage extends StatelessWidget {
  final Illusts illust;

  const GoToLoginPage({Key? key, required this.illust}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(illust.title),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              PixivImage(illust.imageUrls.medium),
              Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: PainterAvatar(
                      id: illust.user.id,
                      url: illust.user.profileImageUrls.medium,
                      onTap: () {},
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(illust.user.name),
                      ),
                      Text(illust.createDate),
                    ],
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class LoginInFirst extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
            child: Text(
              '>_<',
              style: TextStyle(fontSize: 26),
            ),
          ),
          Center(
              child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(I18n.of(context).login_message),
          )),
          ElevatedButton(
            child: Text(I18n.of(context).go_to_login),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (BuildContext context) {
                return LoginPage();
              }));
            },
          )
        ],
      ),
    );
  }
}

class PreviewPage extends StatefulWidget {
  @override
  PreviewPageStateBase createState() {
    if (Constants.isFluentUI)
      return FluentPreviewPageState();
    else
      return MaterialPreviewPageState();
  }
}

abstract class PreviewPageStateBase extends State<PreviewPage> {
  late LightingStore lightingStore;
  RefreshController easyRefreshController =
      RefreshController(initialRefresh: true);

  @override
  void initState() {
    lightingStore = LightingStore(
        ApiSource(futureGet: () => apiClient.walkthroughIllusts()),
        easyRefreshController);
    super.initState();
  }

  @override
  void dispose() {
    easyRefreshController.dispose();
    super.dispose();
  }
}
