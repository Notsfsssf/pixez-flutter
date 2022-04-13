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

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/component/fluent_pixiv_image.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/lighting/lighting_store.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/preview/preview_page.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

class FluentPreviewPage extends StatefulWidget {
  @override
  _FluentPreviewPageState createState() => _FluentPreviewPageState();
}

class _FluentPreviewPageState extends State<FluentPreviewPage> {
  late LightingStore _lightingStore;
  RefreshController _easyRefreshController =
      RefreshController(initialRefresh: true);

  @override
  void initState() {
    _lightingStore = LightingStore(
        ApiSource(futureGet: () => apiClient.walkthroughIllusts()),
        _easyRefreshController);
    super.initState();
  }

  @override
  void dispose() {
    _easyRefreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      return SafeArea(
        child: SmartRefresher(
          controller: _easyRefreshController,
          onRefresh: () => _lightingStore.fetch(url: "walkthrough"),
          onLoading: () => _lightingStore.fetchNext(),
          child: _lightingStore.iStores.isNotEmpty
              ? WaterfallFlow.builder(
                  shrinkWrap: true,
                  gridDelegate:
                      SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                  ),
                  itemBuilder: (BuildContext context, int index) =>
                      _getImageItem(context, index),
                  itemCount: _lightingStore.iStores.length,
                )
              : Container(),
        ),
      );
    });
  }

  Widget _getImageItem(BuildContext context, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
      child: HoverButton(
        onTapUp: () {
          Navigator.of(context).push(FluentPageRoute(
              builder: (BuildContext context) => GoToLoginPage(
                  illust: _lightingStore.iStores[index].illusts!)));
        },
        builder: (context, state) {
          return Card(
            backgroundColor: Colors.transparent,
            padding: const EdgeInsets.all(0.0),
            child: FocusBorder(
              focused: state.isFocused,
              child: Tooltip(
                useMousePosition: true,
                message: '\nTitle: ${_lightingStore.iStores[index].illusts!.title}\n' +
                    'Author: ${_lightingStore.iStores[index].illusts!.user}\n' +
                    'Page Count: ${_lightingStore.iStores[index].illusts!.pageCount}\n',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FluentPixivImage(_lightingStore
                        .iStores[index].illusts!.imageUrls.medium),
                    Acrylic(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(_lightingStore.iStores[index].illusts!.title),
                          Text(
                              _lightingStore.iStores[index].illusts!.user.name),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
