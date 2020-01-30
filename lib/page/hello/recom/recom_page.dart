import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pixez/bloc/account_bloc.dart';
import 'package:pixez/bloc/account_state.dart';
import 'package:pixez/component/illust_card.dart';
import 'package:pixez/component/spotlight_card.dart';
import 'package:pixez/generated/i18n.dart';
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
            RepositoryProvider.of<ApiClient>(context),
          ),
        ),
        BlocProvider<SpotlightBloc>(
          create: (BuildContext context) =>
              SpotlightBloc(RepositoryProvider.of<ApiClient>(context))
          ,
        )
      ],
      child: BlocListener<RecomBloc, RecomState>(
          listener: (context, state) {
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
          },
          child: Scaffold(
              body: SafeArea(
                  bottom: false,
                  child: BlocBuilder<AccountBloc, AccountState>(
                      builder: (context, snapshot) {
                    if (snapshot is HasUserState)
                      return _buildBlocBuilder();
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
                                      fontWeight: FontWeight.bold,
                                      fontSize: 30.0),
                                ),
                                padding:
                                    EdgeInsets.only(left: 20.0, bottom: 10.0),
                              ),
                            ),
                            Expanded(child: PreviewPage())
                          ],
                        ),
                      );
                  })))),
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
                itemCount: state.illusts.length + 2,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Row(
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
                    );
                  }
                  if (index == 1) {
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
                                mainAxisAlignment: MainAxisAlignment
                                    .spaceBetween,
                                children: <Widget>[
                                  Container(
                                    child: Padding(
                                      child: Container(
                                        child: Text(
                                          I18n
                                              .of(context)
                                              .Recommend_for_you,
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
                                      child: Text(I18n
                                          .of(context)
                                          .More),
                                      onPressed: () {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (
                                                    BuildContext context) {
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
                  return IllustCard(state.illusts[index - 2]);
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
