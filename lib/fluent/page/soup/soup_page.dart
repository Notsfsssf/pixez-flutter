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
import 'package:pixez/fluent/component/painter_avatar.dart';
import 'package:pixez/fluent/component/pixez_button.dart';
import 'package:pixez/fluent/component/pixiv_image.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/amwork.dart';
import 'package:pixez/models/spotlight_response.dart';
import 'package:pixez/fluent/page/picture/illust_lighting_page.dart';
import 'package:pixez/page/picture/illust_store.dart';
import 'package:pixez/page/soup/soup_store.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

class SoupPage extends StatefulWidget {
  final String url;
  final SpotlightArticle? spotlight;
  final String? heroTag;

  SoupPage({Key? key, required this.url, required this.spotlight, this.heroTag})
      : super(key: key);

  @override
  _SoupPageState createState() => _SoupPageState();
}

class _SoupPageState extends State<SoupPage> {
  final SoupStore _soupStore = SoupStore();

  @override
  void initState() {
    _soupStore.fetch(widget.url);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: PageHeader(
        title: Text(widget.spotlight!.pureTitle),
        commandBar: widget.spotlight != null
            ? CommandBar(
                mainAxisAlignment: MainAxisAlignment.end,
                primaryItems: [
                  CommandBarButton(
                    icon: Icon(FluentIcons.share),
                    onPressed: () async {
                      var url = widget.spotlight!.articleUrl;
                      await launchUrl(Uri.tryParse(url)!);
                    },
                  )
                ],
              )
            : null,
      ),
      content: Observer(builder: (context) {
        return buildBlocProvider();
      }),
    );
  }

  Widget buildBlocProvider() {
    if (_soupStore.amWorks.isEmpty) return Container();
    final count = (MediaQuery.of(context).orientation == Orientation.portrait)
        ? userSetting.crossCount
        : userSetting.hCrossCount;

    return CustomScrollView(
      slivers: [
        SliverWaterfallFlow(
          gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
            crossAxisCount: count,
          ),
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              return Builder(builder: (context) {
                if (index == 0) {
                  if (_soupStore.description == null ||
                      _soupStore.description!.isEmpty)
                    return Container(
                      height: 1,
                    );
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(_soupStore.description ?? ''),
                    ),
                  );
                }
                AmWork amWork = _soupStore.amWorks[index - 1];
                return PixEzButton(
                  child: Card(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: <Widget>[
                        PixivImage(amWork.showImage!),
                        ListTile(
                          leading: PainterAvatar(
                            url: amWork.userImage!,
                            id: int.parse(Uri.parse(amWork.userLink!)
                                .pathSegments[Uri.parse(amWork.userLink!)
                                    .pathSegments
                                    .length -
                                1]),
                          ),
                          title: Text(amWork.title!),
                          subtitle: Text(amWork.user!),
                        ),
                      ],
                    ),
                  ),
                  onPressed: () {
                    int id = int.parse(Uri.parse(amWork.arworkLink!)
                            .pathSegments[
                        Uri.parse(amWork.arworkLink!).pathSegments.length - 1]);
                    Leader.push(
                      context,
                      IllustLightingPage(
                        id: id,
                        store: IllustStore(id, null),
                      ),
                      icon: Icon(FluentIcons.picture),
                      title: Text(I18n.of(context).illust_id + ': ${id}'),
                    );
                  },
                );
              });
            },
            childCount: _soupStore.amWorks.length + 1,
          ),
        )
      ],
    );
  }
}
