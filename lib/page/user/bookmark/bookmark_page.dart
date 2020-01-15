import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pixez/component/illust_card.dart';
import 'package:pixez/page/user/bookmark/bloc.dart';

class BookmarkPage extends StatefulWidget {
  final int id;
  final String restrict;

  const BookmarkPage({Key key, this.id, this.restrict = "public"})
      : super(key: key);

  @override
  _BookmarkPageState createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> {
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
  Widget build(BuildContext context) {
    return BlocListener<BookmarkBloc, BookmarkState>(
      listener: (context, state) {
        if (state is DataBookmarkState) {
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
      child: BlocBuilder<BookmarkBloc, BookmarkState>(
        builder: (context, state) {
          return EasyRefresh(
            controller: _easyRefreshController,
            firstRefresh: true,
            child: state is DataBookmarkState
                ? StaggeredGridView.countBuilder(
                    crossAxisCount: 2,
                    itemCount: state.illusts.length,
                    itemBuilder: (context, index) {
                      return IllustCard(state.illusts[index]);
                    },
                    staggeredTileBuilder: (int index) => StaggeredTile.fit(1),
                  )
                : Container(),
            onRefresh: () async {
              BlocProvider.of<BookmarkBloc>(context)
                  .add(FetchBookmarkEvent(widget.id, widget.restrict));
              return _refreshCompleter.future;
            },
            onLoad: () async {
              if (state is DataBookmarkState) {
                BlocProvider.of<BookmarkBloc>(context)
                    .add(LoadMoreEvent(state.nextUrl, state.illusts));
                return _loadCompleter.future;
              }
              return;
            },
          );
        },
      ),
    );
  }
}
