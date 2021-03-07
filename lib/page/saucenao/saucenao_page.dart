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
import 'package:pixez/generated/l10n.dart';
import 'package:pixez/page/picture/illust_lighting_page.dart';
import 'package:pixez/page/saucenao/sauce_store.dart';

class SauceNaoPage extends StatefulWidget {
  final String? path;

  const SauceNaoPage({Key? key, this.path}) : super(key: key);

  @override
  _SauceNaoPageState createState() => _SauceNaoPageState();
}

class _SauceNaoPageState extends State<SauceNaoPage> {
  SauceStore _store = SauceStore();

  @override
  void dispose() {
    _store.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _store.observableStream.listen((event) {
      if (event != null && _store.results.isNotEmpty) {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => PageView(
                  children: _store.results
                      .map((element) => IllustLightingPage(id: element))
                      .toList(),
                )));
      }
    });
    if (widget.path != null) {
      _store.findImage(path: widget.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add_photo_alternate),
        onPressed: () {
          _store.findImage();
        },
      ),
      appBar: AppBar(
        title: Icon(Icons.dashboard),
      ),
      body: Container(
        child: ListView(
          children: <Widget>[
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Center(child: Text('SauceNao')),
              ),
            ),
            Observer(builder: (_) {
              if (_store.notStart) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(widget.path ?? ""),
                  ),
                );
              }
              return InkWell(
                child: Card(
                  child: _store.results.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(I18n.of(context).tap_to_show_results(
                              _store.results.length.toString())),
                        )
                      : Container(
                          child: Image.asset(
                            'assets/images/nine.jpg',
                          ),
                        ),
                ),
                onTap: () {
                  if (_store.results.isNotEmpty) {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => PageView(
                              children: _store.results
                                  .map((element) =>
                                      IllustLightingPage(id: element))
                                  .toList(),
                            )));
                  }
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}
