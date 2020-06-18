import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_easyrefresh/material_header.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pixez/component/illust_card.dart';
import 'package:pixez/lighting/lighting_store.dart';
import 'package:pixez/network/api_client.dart';

class LightingList extends StatefulWidget {
  final EasyRefreshController controller;
  final FutureGet source;
  final Widget header;

  const LightingList({
    Key key,
    @required this.source,
    this.controller,
    this.header,
  }) : super(key: key);

  @override
  _LightingListState createState() => _LightingListState();
}

class _LightingListState extends State<LightingList> {
  LightingStore _store;
  EasyRefreshController _easyRefreshController;

  @override
  void didUpdateWidget(LightingList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.source != widget.source) {
      _store.source = widget.source;
      _store.fetch();
      // _easyRefreshController.callRefresh();
    }
  }

  @override
  void initState() {
    _easyRefreshController = widget.controller ?? EasyRefreshController();
    _store = LightingStore(widget.source,
        RepositoryProvider.of<ApiClient>(context), _easyRefreshController);
    super.initState();
    _store.fetch();
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
        header: MaterialHeader(),
        controller: _easyRefreshController,
        enableControlFinishLoad: true,
        enableControlFinishRefresh: true,
        onRefresh: () {
          return _store.fetch();
        },
        onLoad: () {
          return _store.fetchNext();
        },
        child: _store.illusts.isNotEmpty
            ? StaggeredGridView.countBuilder(
                crossAxisCount: 2,
                padding: EdgeInsets.all(0.0),
                itemBuilder: (context, index) {
                  if (widget.header == null) {
                    final data = _store.illusts[index];
                    return IllustCard(
                      data,
                      illustList: _store.illusts,
                    );
                  } else {
                    if (index == 0)
                      return widget.header;
                    else {
                      final data = _store.illusts[index - 1];
                      return IllustCard(data, illustList: _store.illusts);
                    }
                  }
                },
                staggeredTileBuilder: (int index) {
                  return StaggeredTile.fit(
                      widget.header != null && index == 0 ? 2 : 1);
                },
                itemCount: widget.header != null
                    ? _store.illusts.length + 1
                    : _store.illusts.length,
              )
            : Container(),
      );
    });
  }
}
