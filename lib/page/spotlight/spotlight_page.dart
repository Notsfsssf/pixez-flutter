import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pixez/component/spotlight_card.dart';
import 'package:pixez/generated/l10n.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/hello/recom/bloc.dart';

class SpotLightPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var _easyController = EasyRefreshController();
    var _controller = ScrollController();
    var _refreshCompleter = Completer<void>();
    var _loadCompleter = Completer<void>();
    return BlocProvider<SpotlightBloc>(
      child: Scaffold(
        appBar: AppBar(
          title: Text(I18n.of(context).Spotlight),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.arrow_upward), onPressed: () {
                        _controller.animateTo(0,
                duration: Duration(seconds: 1), curve: Curves.ease);
              },
            )
          ],
        ),
  
        body: BlocListener<SpotlightBloc, SpotlightState>(
          child: BlocBuilder<SpotlightBloc, SpotlightState>(
              builder: (context, snapshot) {
            if (snapshot is DataSpotlight)
              return EasyRefresh(
                  controller: _easyController,
                  onLoad: () {
                    print("next:${snapshot.nextUrl}");
                    BlocProvider.of<SpotlightBloc>(context).add(
                        LoadMoreSpolightEvent(
                            snapshot.articles, snapshot.nextUrl));
                    return _loadCompleter.future;
                  },
                  child: StaggeredGridView.countBuilder(
                    crossAxisCount: 3,
                    controller: _controller,
                    itemBuilder: (BuildContext context, int index) {
                      return SpotlightCard(spotlight: snapshot.articles[index]);
                    },
                    staggeredTileBuilder: (int index) => StaggeredTile.fit(1),
                    itemCount: snapshot.articles.length,
                  ));
                else
                  return Center(
                    child: CircularProgressIndicator(),
                  );
              }),
          listener: (BuildContext context, state) {
            if (state is DataSpotlight) {
              _loadCompleter?.complete();
              _loadCompleter = Completer();
              _refreshCompleter?.complete();
              _refreshCompleter = Completer();
            }
          },
        ),
      ),
      create: (BuildContext context) =>
      SpotlightBloc(RepositoryProvider.of<ApiClient>(context))
        ..add(FetchSpotlightEvent()),
    );
  }
}
