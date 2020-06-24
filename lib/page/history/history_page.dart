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
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixez/bloc/bloc.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/generated/l10n.dart';
import 'package:pixez/page/picture/picture_page.dart';

class HistoryPage extends StatelessWidget {
  Widget buildAppBarUI(context) => Container(
        child: Padding(
          child: Text(
            I18n.of(context).History,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30.0),
          ),
          padding: EdgeInsets.only(left: 20.0, top: 30.0, bottom: 30.0),
        ),
      );

  Widget buildBody() => BlocBuilder<IllustPersistBloc, IllustPersistState>(
          builder: (context, state) {
        if (state is DataIllustPersistState)
        {
          var reIllust = state.illusts.reversed.toList();
          return GridView.builder(
              itemCount: reIllust.length,
              gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
              itemBuilder: (context, index) {
                return GestureDetector(
                    onTap: () {
                      Navigator.of(context,rootNavigator: true).push(
                          MaterialPageRoute(builder: (BuildContext context) {
                            return PicturePage(null,reIllust[index].illustId);
                          }));
                    },
                    onLongPress: () async {
                      final result = await showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text("${I18n.of(context).Delete}?"),
                              actions: <Widget>[
                                FlatButton(
                                  child: Text("OK"),
                                  onPressed: () {
                                    Navigator.of(context).pop("OK");
                                  },
                                )
                              ],
                            );
                          });
                      if (result == "OK") {
                        BlocProvider.of<IllustPersistBloc>(context).add(
                            DeleteIllustPersistEvent(reIllust[index].illustId));
                      }
                    },
                    child: Card(
                      margin: EdgeInsets.all(8),
                      child: PixivImage(reIllust[index].pictureUrl)));
              });
        }
        else
          return Center(
            child: CircularProgressIndicator(),
          );
      });

  @override
  Widget build(BuildContext context) {
    BlocProvider.of<IllustPersistBloc>(context).add(FetchIllustPersistEvent());
    return Scaffold(
      appBar: AppBar(
        title: Text(I18n.of(context).History),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.clear_all),
            onPressed: () async {
              final result = await showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text("${I18n.of(context).Delete} All?"),
                      actions: <Widget>[
                        FlatButton(
                          child: Text("OK"),
                          onPressed: () {
                            Navigator.of(context).pop("OK");
                          },
                        )
                      ],
                    );
                  });
              if (result == "OK") {
                BlocProvider.of<IllustPersistBloc>(context)
                    .add(DeleteAllIllustPersistEvent());
              }
            },
          )
        ],
      ),
      body: buildBody(),
    );
  }
}
