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

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/models/spotlight_response.dart';
import 'package:pixez/page/soup/soup_page.dart';
import 'package:pixez/exts.dart';
import 'package:pixez/main.dart';

class SpotlightCard extends StatelessWidget {
  final SpotlightArticle spotlight;
  static const platform = const MethodChannel('samples.flutter.dev/battery');

  const SpotlightCard({Key? key,required this.spotlight}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(4.0),
      child: GestureDetector(
        onTap: () async {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (BuildContext context) {
            return SoupPage(url: spotlight.articleUrl, spotlight: spotlight);
          }));
        },
        child: Container(
          height: 230,
          child: Stack(
            children: <Widget>[
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: 160.0,
                  height: 90.0,
                  decoration: BoxDecoration(
                      color: Theme.of(context).splashColor,
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
                        )),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Card(
                  elevation: 8.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16.0))),
                  child: Container(
                    child: ExtendedImage.network(
                      spotlight.thumbnail.toTrueUrl(),
                      headers: {
                        "referer": "https://app-api.pixiv.net/",
                        "User-Agent": "PixivIOSApp/5.8.0",
                        "Host": splashStore.host == ImageCatHost
                            ? ImageCatHost
                            : ImageHost
                      },
                      fit: BoxFit.cover,
                      height: 150.0,
                      width: 150.0,
                    ),
                    height: 150.0,
                    width: 150.0,
                  ),
                  clipBehavior: Clip.antiAlias,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
