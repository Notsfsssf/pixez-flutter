import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pixez/component/illust_card.dart';
import 'package:pixez/generated/i18n.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/hello/recom/bloc.dart';

class ReComPage extends StatefulWidget {
  @override
  _ReComPageState createState() => _ReComPageState();
}

class _ReComPageState extends State<ReComPage> {
  Completer<void> _refreshCompleter, _loadCompleter;
  ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _refreshCompleter = Completer<void>();
    _loadCompleter = Completer<void>();
    _scrollController = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) =>
            RecomBloc(RepositoryProvider.of<ApiClient>(context))
              ..add(FetchEvent()),
        child: BlocListener<RecomBloc, RecomState>(
            listener: (context, state) {
              if (state is DataRecomState) {
                _loadCompleter?.complete();
                _loadCompleter = Completer();
                _refreshCompleter?.complete();
                _refreshCompleter = Completer();
              }
            },
            child: Scaffold(
                body: SafeArea(
              child: _buildBlocBuilder(),
            ))));
  }

  BlocBuilder<RecomBloc, RecomState> _buildBlocBuilder() {
    return BlocBuilder<RecomBloc, RecomState>(builder: (context, state) {
      if (state is DataRecomState) return _buildDateBody(state, context);
      return Center(
        child: CircularProgressIndicator(),
      );
    });
  }

  Widget _buildDateBody(DataRecomState state, BuildContext context) {
    return EasyRefresh(
      child: StaggeredGridView.countBuilder(
        crossAxisCount: 2,
        controller: _scrollController,
        padding: EdgeInsets.symmetric(vertical: 30.0),
        itemCount: state.illusts.length + 2,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Container(
              child: Padding(
                child: Text(
                  "Hello",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30.0),
                ),
                padding: EdgeInsets.only(left: 20.0),
              ),
            );
          }
          if (index == 1) {
            return BlocProvider<SpotlightBloc>(
              create: (BuildContext context) =>
              SpotlightBloc(RepositoryProvider.of<ApiClient>(context))
                ..add(FetchSpotlightEvent()),
              child: BlocBuilder<SpotlightBloc, SpotlightState>(
                builder: (BuildContext context, SpotlightState state) {
                  if (state is DataSpotlight) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          height: 200.0,
                          child: ListView.builder(
                            controller: _scrollController,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return Container(
                                height: 200,
                                child: Stack(
                                  children: <Widget>[
                                    Align(
                                      alignment: Alignment.bottomCenter,
                                      child: Container(
                                          height: 100,
                                          child: Column(
                                            children: <Widget>[
                                              Text("111"),
                                              Text("11"),
                                            ],
                                            mainAxisSize: MainAxisSize.max,
                                          )),
                                    ),
                                    Align(
                                      alignment: Alignment.topCenter,
                                      child: Card(
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(16.0))),
                                        child: Container(
                                          child: CachedNetworkImage(
                                            imageUrl: state
                                                .spotlightResponse
                                                .spotlightArticles[index]
                                                .thumbnail,
                                            httpHeaders: {
                                              "referer":
                                              "https://app-api.pixiv.net/",
                                              "User-Agent": "PixivIOSApp/5.8.0"
                                            },
                                            fit: BoxFit.fill,
                                          ),
                                          height: 150.0,
                                          width: 150.0,
                                        ),
                                        clipBehavior: Clip.antiAlias,
                                      ),
                                    )
                                  ],
                                ),
                              );

                              return Card(
                                child: Container(
                                  child: CachedNetworkImage(
                                    imageUrl: state.spotlightResponse
                                        .spotlightArticles[index].thumbnail,
                                    httpHeaders: {
                                      "referer": "https://app-api.pixiv.net/",
                                      "User-Agent": "PixivIOSApp/5.8.0"
                                    },
                                    fit: BoxFit.fill,
                                  ),
                                  height: 80.0,
                                  width: 80.0,
                                ),
                              );
                            },
                            itemCount: state
                                .spotlightResponse.spotlightArticles.length,
                            scrollDirection: Axis.horizontal,
                          ),
                        ),
                        Padding(
                          child: Text(
                            I18n
                                .of(context)
                                .Recommend,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 30.0),
                          ),
                          padding: EdgeInsets.only(left: 20.0),
                        ),
                      ],
                    );
                  }
                  return Container();
                },
              ),
            );
          }
          return IllustCard(state.illusts[index - 2]);
        },
        staggeredTileBuilder: (int index) =>
            StaggeredTile.fit(index == 0 || index == 1 ? 2 : 1),
      ),
      onRefresh: () async {
        BlocProvider.of<RecomBloc>(context).add(FetchEvent());
        return _refreshCompleter.future;
      },
      onLoad: () async {
        BlocProvider.of<RecomBloc>(context)
            .add(LoadMoreEvent(state.nextUrl, state.illusts));
        return _loadCompleter.future;
      },
    );
  }
}
