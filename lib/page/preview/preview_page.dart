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

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pixez/component/painter_avatar.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/generated/l10n.dart';
import 'package:pixez/models/illust.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/login/login_page.dart';
import 'package:pixez/page/preview/bloc.dart';

class GoToLoginPage extends StatelessWidget {
  final Illusts illust;

  const GoToLoginPage({Key key, @required this.illust}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(illust.title),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              PixivImage(illust.imageUrls.medium),
              Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: PainterAvatar(
                      url: illust.user.profileImageUrls.medium,
                      onTap: () {},
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(illust.user.name),
                      ),
                      Text(illust.createDate),
                    ],
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class LoginInFirst extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
            child: Text(
              '>_<',
              style: TextStyle(fontSize: 26),
            ),
          ),
          Center(
              child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(I18n.of(context).Login_message),
          )),
          RaisedButton(
            child: Text(I18n.of(context).Go_to_Login),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (BuildContext context) {
                return LoginPage();
              }));
            },
          )
        ],
      ),
    );
  }
}

class PreviewPage extends StatefulWidget {
  @override
  _PreviewPageState createState() => _PreviewPageState();
}

class _PreviewPageState extends State<PreviewPage> {
  EasyRefreshController _easyRefreshController = EasyRefreshController();
  Completer<void> _refreshCompleter = Completer(), _loadCompleter = Completer();

  @override
  Widget build(BuildContext context) {
    return BlocProvider<WalkThroughBloc>(
      child: BlocListener<WalkThroughBloc, WalkThroughState>(
        child: BlocBuilder<WalkThroughBloc, WalkThroughState>(
            builder: (context, state) {
          return SafeArea(
            child: EasyRefresh(
              onLoad: () async {
                if (state is DataWalkThroughState) {
                  BlocProvider.of<WalkThroughBloc>(context)
                      .add(LoadMoreWalkThroughEvent(
                    state.nextUrl,
                    state.illusts,
                  ));
                  return _loadCompleter.future;
                }
                return;
              },
              controller: _easyRefreshController,
              child: (state is DataWalkThroughState)
                  ? StaggeredGridView.countBuilder(
                      shrinkWrap: true,
                      crossAxisCount: 2,
                      itemBuilder: (BuildContext context, int index) {
                        return InkWell(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    GoToLoginPage(
                                        illust: state.illusts[index])));
                          },
                          child: Card(
                            child: Container(
                              child: PixivImage(
                                  state.illusts[index].imageUrls.squareMedium),
                            ),
                          ),
                        );
                      },
                      itemCount: state.illusts.length,
                      staggeredTileBuilder: (int index) => StaggeredTile.fit(1),
                    )
                  : Container(),
            ),
          );
        }),
        listener: (BuildContext context, WalkThroughState state) {
          if (state is DataWalkThroughState) {
            _loadCompleter?.complete();
            _loadCompleter = Completer();
            _refreshCompleter?.complete();
            _refreshCompleter = Completer();
          }
        },
      ),
      create: (context) =>
          WalkThroughBloc(apiClient)..add(FetchWalkThroughEvent()),
    );
  }
}
