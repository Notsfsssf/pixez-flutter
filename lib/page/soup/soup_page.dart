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
import 'package:pixez/component/null_hero.dart';
import 'package:pixez/component/painter_avatar.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/models/amwork.dart';
import 'package:pixez/models/spotlight_response.dart';
import 'package:pixez/page/picture/illust_lighting_page.dart';
import 'package:pixez/page/picture/illust_store.dart';
import 'package:pixez/page/soup/soup_store.dart';
import 'package:url_launcher/url_launcher_string.dart';

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
    return Scaffold(
      body: Observer(builder: (context) {
        return NestedScrollView(
          body: buildBlocProvider(),
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              if (widget.spotlight != null)
                SliverAppBar(
                  pinned: true,
                  expandedHeight: 200.0,
                  flexibleSpace: FlexibleSpaceBar(
                    centerTitle: true,
                    title: Text(widget.spotlight!.pureTitle),
                    background: NullHero(
                      tag: widget.heroTag,
                      child: PixivImage(
                        widget.spotlight!.thumbnail,
                        fit: BoxFit.cover,
                        height: 200,
                      ),
                    ),
                  ),
                  actions: <Widget>[
                    IconButton(
                      icon: Icon(Icons.share),
                      onPressed: () async {
                        var url = widget.spotlight!.articleUrl;
                        await launchUrlString(url);
                      },
                    )
                  ],
                )
              else
                SliverAppBar()
            ];
          },
        );
      }),
    );
  }

  Widget buildBlocProvider() {
    if (_soupStore.amWorks.isEmpty) return Container();
    return ListView.builder(
      itemBuilder: (BuildContext context, int index) {
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
          return InkWell(
            onTap: () {
              int id = int.parse(Uri.parse(amWork.arworkLink!).pathSegments[
                  Uri.parse(amWork.arworkLink!).pathSegments.length - 1]);
              Navigator.of(context, rootNavigator: true)
                  .push(MaterialPageRoute(builder: (BuildContext context) {
                return IllustLightingPage(
                  id: id,
                  store: IllustStore(id, null),
                );
              }));
            },
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: <Widget>[
                  ListTile(
                    leading: PainterAvatar(
                      url: amWork.userImage!,
                      id: int.parse(Uri.parse(amWork.userLink!).pathSegments[
                          Uri.parse(amWork.userLink!).pathSegments.length - 1]),
                    ),
                    title: Text(amWork.title!),
                    subtitle: Text(amWork.user!),
                  ),
                  PixivImage(amWork.showImage!),
                ],
              ),
            ),
          );
        });
      },
      itemCount: _soupStore.amWorks.length + 1,
    );
  }
}
