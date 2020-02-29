import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pixez/component/illust_card.dart';
import 'package:pixez/page/user/works/bloc.dart';

class WorksPage extends StatefulWidget {
  final int id;

  const WorksPage({Key key, this.id}) : super(key: key);

  @override
  _WorksPageState createState() => _WorksPageState();
}

class _WorksPageState extends State<WorksPage> {
  Completer<void> _refreshCompleter, _loadCompleter;
  EasyRefreshController _easyRefreshController;

  @override
  void initState() {
    super.initState();
    _refreshCompleter = Completer<void>();
    _loadCompleter = Completer<void>();
    _easyRefreshController = EasyRefreshController();
  }

  @override
  void dispose() {
    _easyRefreshController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WorksBloc, WorksState>(
        listener: (context, state) {
          if (state is DataWorksState) {
            _loadCompleter?.complete();
            _loadCompleter = Completer();
            _refreshCompleter?.complete();
            _refreshCompleter = Completer();
          }
          if (state is FailWorkState) {
            _easyRefreshController.finishRefresh(success: false);
          }
          if (state is LoadMoreFailState) {
            _easyRefreshController.finishLoad(success: false);
          }
          if (state is LoadMoreEndState)
            _easyRefreshController.finishLoad(success: true, noMore: true);
        },
        child: BlocBuilder<WorksBloc, WorksState>(
          condition: (pre, now) {
            return now is DataWorksState;
          },
          builder: (context, state) {
            return EasyRefresh(
              firstRefresh: true,
              controller: _easyRefreshController,
              child: state is DataWorksState
                  ? StaggeredGridView.countBuilder(
                      crossAxisCount: 2,
                      itemCount: state.illusts.length,
                      itemBuilder: (context, index) {
                        return IllustCard(
                          state.illusts[index],
                          illustList: state.illusts,
                        );
                      },
                      staggeredTileBuilder: (int index) => StaggeredTile.fit(1),
                    )
                  : Container(),
              onRefresh: () async {
                BlocProvider.of<WorksBloc>(context)
                    .add(FetchWorksEvent(widget.id, "illust"));
                return _refreshCompleter.future;
              },
              onLoad: () async {
                if (state is DataWorksState) {
                  BlocProvider.of<WorksBloc>(context)
                      .add(LoadMoreEvent(state.nextUrl, state.illusts));
                  return _loadCompleter.future;
                }
                return;
              },
            );
          },
        ));
  }
}
