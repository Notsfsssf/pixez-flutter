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

import 'dart:math';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/fluent/component/painter_avatar.dart';
import 'package:pixez/fluent/component/pixiv_image.dart';
import 'package:pixez/fluent/page/login/login_page.dart';
import 'package:pixez/utils.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/lighting/lighting_store.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/illust.dart';
import 'package:pixez/network/api_client.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

class GoToLoginPage extends StatelessWidget {
  final Illusts illust;

  const GoToLoginPage({Key? key, required this.illust}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: PageHeader(title: Text(illust.title)),
      content: SafeArea(
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
    return ScaffoldPage(
      content: Column(
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
          FilledButton(
            child: Text(I18n.of(context).go_to_login),
            onPressed: () {
              Leader.push(
                context,
                LoginPage(),
                icon: Icon(FluentIcons.people),
                title: Text(I18n.of(context).login),
              );
            },
          )
        ],
      ),
    );
  }
}

class PreviewPage extends StatefulWidget {
  @override
  _PreviewPageState createState() => _PreviewPageState();
}

class _PreviewPageState extends State<PreviewPage> {
  final LightingStore _lightingStore = LightingStore(
    ApiSource(futureGet: () => apiClient.walkthroughIllusts()),
  );
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    _lightingStore.easyRefreshController = EasyRefreshController(
        controlFinishLoad: true, controlFinishRefresh: true);
    _lightingStore.fetch(url: "walkthrough");
    initializeScrollController(_scrollController, _lightingStore.fetchNext);

    super.initState();
  }

  @override
  void dispose() {
    _lightingStore.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    var count = 0;
    if (userSetting.crossAdapt) {
      count = _buildSliderValue(context, orientation);
    } else {
      count = (orientation == Orientation.portrait)
          ? userSetting.crossCount
          : userSetting.hCrossCount;
    }

    return Observer(builder: (_) {
      return SafeArea(
        child: EasyRefresh(
          refreshOnStart: true,
          controller: _lightingStore.easyRefreshController,
          onRefresh: () => _lightingStore.fetch(url: "walkthrough"),
          onLoad: () => _lightingStore.fetchNext(),
          child: WaterfallFlow.builder(
            controller: _scrollController,
            shrinkWrap: true,
            gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
              crossAxisCount: count,
            ),
            itemBuilder: (BuildContext context, int index) {
              return IconButton(
                onPressed: () {
                  Leader.push(
                    context,
                    GoToLoginPage(
                      illust: _lightingStore.iStores[index].illusts!,
                    ),
                    icon: Icon(FluentIcons.picture),
                    title: Text(
                        '${I18n.of(context).illust}: ${_lightingStore.iStores[index].illusts}'),
                  );
                },
                icon: Card(
                  child: Container(
                    child: PixivImage(_lightingStore
                        .iStores[index].illusts!.imageUrls.squareMedium),
                  ),
                ),
              );
            },
            itemCount: _lightingStore.iStores.length,
          ),
        ),
      );
    });
  }

  int _buildSliderValue(BuildContext context, Orientation orientation) {
    final currentValue = (orientation == Orientation.portrait
            ? userSetting.crossAdapterWidth
            : userSetting.hCrossAdapterWidth)
        .toDouble();
    var nowAdaptWidth = max(currentValue, 50.0);
    nowAdaptWidth = min(nowAdaptWidth, 2160);
    return max((MediaQuery.of(context).size.width / nowAdaptWidth), 1.0)
        .toInt();
  }
}
