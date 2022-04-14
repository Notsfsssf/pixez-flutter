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
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/component/painter_avatar.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/lighting/lighting_store.dart';
import 'package:pixez/models/illust.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/login/login_page.dart';
import 'package:pixez/page/preview/preview_page.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

class MaterialPreviewPageState extends PreviewPageStateBase {
  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      return SafeArea(
        child: SmartRefresher(
          controller: easyRefreshController,
          onRefresh: () => lightingStore.fetch(url: "walkthrough"),
          onLoading: () => lightingStore.fetchNext(),
          child: lightingStore.iStores.isNotEmpty
              ? WaterfallFlow.builder(
                  shrinkWrap: true,
                  gridDelegate:
                      SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) => GoToLoginPage(
                                illust:
                                    lightingStore.iStores[index].illusts!)));
                      },
                      child: Card(
                        child: Container(
                          child: PixivImage(lightingStore
                              .iStores[index].illusts!.imageUrls.squareMedium),
                        ),
                      ),
                    );
                  },
                  itemCount: lightingStore.iStores.length,
                )
              : Container(),
        ),
      );
    });
  }
}
