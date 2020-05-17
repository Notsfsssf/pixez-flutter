import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pixez/component/illust_card.dart';
import 'package:pixez/lighting/lighting_store.dart';
import 'package:pixez/network/api_client.dart';

class LightingList extends StatefulWidget {
  final Future<Response> source;
  final EasyRefreshController controller;
  const LightingList({Key key, @required this.source, this.controller})
      : super(key: key);
  @override
  _LightingListState createState() => _LightingListState();
}

class _LightingListState extends State<LightingList> {
  LightingStore _store;
  EasyRefreshController _easyRefreshController;
  @override
  void initState() {
    _easyRefreshController = widget.controller ?? EasyRefreshController();
    _store = LightingStore(widget.source,
        RepositoryProvider.of<ApiClient>(context), _easyRefreshController);
    super.initState();
  }

  @override
  void dispose() {
    _easyRefreshController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      return EasyRefresh(
        firstRefresh: true,
        enableControlFinishLoad: true,
        enableControlFinishRefresh: true,
        onRefresh: () {
          return _store.fetch();
        },
        onLoad: () {
          return _store.fetchNext();
        },
        controller: _easyRefreshController,
        child: _store.illusts.isNotEmpty
            ? StaggeredGridView.countBuilder(
                crossAxisCount: 2,
                itemBuilder: (context, index) {
                  final data = _store.illusts[index];
                  return IllustCard(data);
                },
                staggeredTileBuilder: (int index) {
                  return StaggeredTile.fit(1);
                },
                itemCount: _store.illusts.length,
              )
            : Container(),
      );
    });
  }
}
