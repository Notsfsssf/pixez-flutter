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

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:pixez/fluent/component/pixez_button.dart';
import 'package:pixez/fluent/component/pixiv_image.dart';
import 'package:pixez/er/hoster.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/models/spotlight_response.dart';
import 'package:pixez/fluent/page/soup/soup_page.dart';

class SpotlightCard extends StatelessWidget {
  final SpotlightArticle spotlight;
  static const platform = const MethodChannel('samples.flutter.dev/battery');

  const SpotlightCard({Key? key, required this.spotlight}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PixEzButton(
      child: Container(
        height: 200,
        child: Card(
          padding: EdgeInsets.zero,
          child: Stack(
            children: <Widget>[
              Align(
                alignment: Alignment.bottomCenter,
                child: ListTile(
                  title: Text(
                    spotlight.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    spotlight.pureTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: CachedNetworkImage(
                  imageUrl: spotlight.thumbnail,
                  httpHeaders: Hoster.header(url: spotlight.thumbnail),
                  fit: BoxFit.cover,
                  height: 150.0,
                  cacheManager: pixivCacheManager,
                ),
              )
            ],
          ),
        ),
      ),
      onPressed: () async {
        Leader.push(
          context,
          SoupPage(url: spotlight.articleUrl, spotlight: spotlight),
          icon: const Icon(FluentIcons.image_pixel),
          title: Text("${I18n.of(context).spotlight}: ${spotlight.id}"),
        );
      },
    );
  }
}
