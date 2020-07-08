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
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pixez/component/illust_card.dart';
import 'package:pixez/component/spotlight_card.dart';
import 'package:pixez/generated/l10n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/hello/ranking/ranking_page.dart';
import 'package:pixez/page/hello/recom/bloc.dart';
import 'package:pixez/page/preview/preview_page.dart';
import 'package:pixez/page/spotlight/spotlight_page.dart';

class ReComPage extends StatefulWidget {
  @override
  _ReComPageState createState() => _ReComPageState();
}

class _ReComPageState extends State<ReComPage> {
  Completer<void> _refreshCompleter, _loadCompleter;
  ScrollController _scrollController;
  EasyRefreshController _easyRefreshController;

  @override
  void initState() {
    super.initState();
    _refreshCompleter = Completer<void>();
    _loadCompleter = Completer<void>();
    _scrollController = ScrollController();
    _easyRefreshController = EasyRefreshController();
  }

  @override
  void dispose() {
    super.dispose();
    _easyRefreshController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<RecomBloc>(
          create: (context) => RecomBloc(
            apiClient,
          ),
        ),
        BlocProvider<SpotlightBloc>(
          create: (BuildContext context) => SpotlightBloc(apiClient),
        )
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<RecomBloc, RecomState>(listener: (context, state) {
            _loadCompleter?.complete();
            _loadCompleter = Completer();
            _refreshCompleter?.complete();
            _refreshCompleter = Completer();
            if (state is DataRecomState) {}
            if (state is FailRecomState) {
              _easyRefreshController.finishRefresh(success: false);
            }
            if (state is LoadMoreEndState) {
              _easyRefreshController.finishLoad(success: true, noMore: true);
            }
          }),
        ],
        child: Scaffold(body: Observer(builder: (context) {
          if (accountStore.now != null)
            return Column(children: <Widget>[
              AppBar(
                automaticallyImplyLeading: false,
                backgroundColor: Colors.transparent,
                elevation: 0.0,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      child: Padding(
                        child: Text(
                          I18n.of(context).Spotlight,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 30.0),
                        ),
                        padding: EdgeInsets.only(left: 20.0, bottom: 10.0),
                      ),
                    ),
                    Padding(
                      child: FlatButton(
                        child: Text(I18n.of(context).More),
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (BuildContext context) {
                            return SpotLightPage();
                          }));
                        },
                      ),
                      padding: EdgeInsets.all(8.0),
                    )
                  ],
                ),
              ),
              Expanded(child: _buildBlocBuilder())
            ]);
          else
            return Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    child: Padding(
                      child: Text(
                        I18n.of(context).Spotlight,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 30.0),
                      ),
                      padding: EdgeInsets.only(left: 20.0, bottom: 10.0),
                    ),
                  ),
                  Expanded(child: PreviewPage())
                ],
              ),
            );
        })),
      ),
    );
  }

  BlocBuilder<RecomBloc, RecomState> _buildBlocBuilder() {
    return BlocBuilder<RecomBloc, RecomState>(condition: (pre, now) {
      return now is DataRecomState;
    }, builder: (context, state) {
      return EasyRefresh(
        firstRefresh: true,
        controller: _easyRefreshController,
        child: state is DataRecomState
            ? StaggeredGridView.countBuilder(
                crossAxisCount: 2,
                controller: _scrollController,
                padding: EdgeInsets.symmetric(vertical: 30.0),
                itemCount: state.illusts.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return BlocBuilder<SpotlightBloc, SpotlightState>(
                      builder: (BuildContext context, SpotlightState state) {
                        if (state is DataSpotlight) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Container(
                                height: 230.0,
                                child: ListView.builder(
                                  controller: _scrollController,
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    final spotlight = state.articles[index];
                                    return SpotlightCard(
                                      spotlight: spotlight,
                                    );
                                  },
                                  itemCount: state.articles.length,
                                  scrollDirection: Axis.horizontal,
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Container(
                                    child: Padding(
                                      child: Container(
                                        child: Text(
                                          I18n.of(context).Recommend_for_you,
                                          overflow: TextOverflow.clip,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 30.0),
                                        ),
                                      ),
                                      padding: EdgeInsets.only(
                                          left: 20.0, bottom: 10.0),
                                    ),
                                  ),
                                  Padding(
                                    child: FlatButton(
                                      child: Text(I18n.of(context).More),
                                      onPressed: () {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(builder:
                                                (BuildContext context) {
                                          return RankingPage();
                                        }));
                                      },
                                    ),
                                    padding: EdgeInsets.all(8.0),
                                  )
                                ],
                              ),
                            ],
                          );
                        }
                        return Container();
                      },
                    );
                  }
                  return IllustCard(
                    state.illusts[index - 1],
                    illustList: state.illusts,
                  );
                },
                staggeredTileBuilder: (int index) =>
                    StaggeredTile.fit(index == 0 || index == 1 ? 2 : 1),
              )
            : Center(),
        onRefresh: () async {
          BlocProvider.of<RecomBloc>(context).add(FetchEvent());
          BlocProvider.of<SpotlightBloc>(context).add(FetchSpotlightEvent());
          return _refreshCompleter.future;
        },
        onLoad: () async {
          if (state is DataRecomState) {
            BlocProvider.of<RecomBloc>(context)
                .add(LoadMoreEvent(state.nextUrl, state.illusts));
            return _loadCompleter.future;
          }
          return;
        },
      );
    });
  }
}
