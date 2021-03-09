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
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/exts.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/page/picture/illust_about_store.dart';
import 'package:pixez/page/picture/illust_lighting_page.dart';

class IllustAboutGrid extends StatefulWidget {
  final int id;

  const IllustAboutGrid({Key? key, required this.id}) : super(key: key);

  @override
  _IllustAboutGridState createState() => _IllustAboutGridState();
}

class _IllustAboutGridState extends State<IllustAboutGrid> {
  late IllustAboutStore _store;

  @override
  void initState() {
    _store = IllustAboutStore(widget.id)..fetch();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      _store.illusts.removeWhere((element) => element.hateByUser());
      if (_store.errorMessage != null) {
        return Container(
          height: 300,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(':(', style: Theme.of(context).textTheme.headline4),
              ),
              RaisedButton(
                onPressed: () {
                  _store.fetch();
                },
                child: Text(I18n.of(context).refresh),
              )
            ],
          ),
        );
      }
      if (_store.illusts.isNotEmpty)
        return GridView.builder(
            padding: EdgeInsets.all(0.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, //
            ),
            shrinkWrap: true,
            itemCount: _store.illusts.length,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (BuildContext context) {
                    return IllustLightingPage(
                      id: _store.illusts[index].id,
                    );
                  }));
                },
                child: PixivImage(
                  _store.illusts[index].imageUrls.squareMedium,
                  enableMemoryCache: false,
                ),
              );
            });
      return Container(
        height: 200,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    });
  }
}
