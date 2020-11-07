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
import 'package:pixez/page/picture/illust_about_store.dart';

class IllustAboutSliver extends StatefulWidget {
  final int id;

  const IllustAboutSliver({Key key, this.id}) : super(key: key);
  @override
  _IllustAboutSliverState createState() => _IllustAboutSliverState();
}

class _IllustAboutSliverState extends State<IllustAboutSliver> {
  IllustAboutStore _aboutStore;
  @override
  void initState() {
    _aboutStore = IllustAboutStore(widget.id)..fetch();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      if (_aboutStore.errorMessage != null) {
        return SliverToBoxAdapter(
          child: Container(
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
                    _aboutStore.fetch();
                  },
                  child: Text('Refresh'),
                )
              ],
            ),
          ),
        );
      }
      if (_aboutStore.illusts.isNotEmpty)
        return SliverGrid(
            delegate:
                SliverChildBuilderDelegate((BuildContext context, int index) {
              return Container();
            }, childCount: 1),
            gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3));
      return SliverToBoxAdapter(
        child: Container(
          height: 200,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    });
  }
}
