import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pixez/component/spotlight_card.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/hello/recom/bloc.dart';

class SpotLightPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var _refreshCompleter = Completer<void>();
    var _loadCompleter = Completer<void>();
    return BlocProvider<SpotlightBloc>(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Spotlight"),
        ),
        body: BlocListener<SpotlightBloc, SpotlightState>(
          child: BlocBuilder<SpotlightBloc, SpotlightState>(
              builder: (context, snapshot) {
            if (snapshot is DataSpotlight)
              return EasyRefresh(
                  onLoad: () {
                    BlocProvider.of<SpotlightBloc>(context).add(
                        LoadMoreSpolightEvent(
                            snapshot.nextUrl,
                            snapshot.articles));
                    return _loadCompleter.future;
                  },
                  child: StaggeredGridView.countBuilder(
                    crossAxisCount: 3,
                    itemBuilder: (BuildContext context, int index) {
                      return SpotlightCard(
                          spotlight: snapshot
                              .articles[index]);
                    },
                    staggeredTileBuilder: (int index) => StaggeredTile.fit(1),
                    itemCount:
                        snapshot.articles.length,
                  ));
            else
              return Center(
                child: CircularProgressIndicator(),
              );
          }),
          listener: (BuildContext context, state) {
            _loadCompleter?.complete();
            _loadCompleter = Completer();
            _refreshCompleter?.complete();
            _refreshCompleter = Completer();
          },
        ),
      ),
      create: (BuildContext context) =>
          SpotlightBloc(RepositoryProvider.of<ApiClient>(context))
            ..add(FetchSpotlightEvent()),
    );
  }
}
