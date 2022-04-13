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
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/component/spotlight_card.dart';
import 'package:pixez/er/hoster.dart';
import 'package:pixez/models/spotlight_response.dart';
import 'package:pixez/page/soup/soup_page.dart';

class FluentSpotlightCard extends SpotlightCardBase {
  FluentSpotlightCard({required SpotlightArticle spotlight})
      : super(spotlight: spotlight);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(4.0),
      child: HoverButton(onPressed: () async {
        Navigator.of(context)
            .push(FluentPageRoute(builder: (BuildContext context) {
          return SoupPage(url: spotlight.articleUrl, spotlight: spotlight);
        }));
      }, builder: (context, state) {
        return FocusBorder(
          focused: state.isFocused || state.isHovering,
          child: Container(
            height: 220,
            child: Stack(
              children: <Widget>[
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Acrylic(
                    child: Container(
                      width: 160.0,
                      height: 70.0,
                      decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.all(Radius.circular(8.0))),
                      child: Align(
                        alignment: AlignmentDirectional.bottomCenter,
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
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: Card(
                    elevation: 8.0,
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    padding: EdgeInsets.all(5.0),
                    child: Container(
                      child: CachedNetworkImage(
                        imageUrl: spotlight.thumbnail,
                        httpHeaders: Hoster.header(url: spotlight.thumbnail),
                        fit: BoxFit.cover,
                        height: 150.0,
                        cacheManager: pixivCacheManager,
                        width: 150.0,
                      ),
                      height: 150.0,
                      width: 150.0,
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      }),
    );
  }
}