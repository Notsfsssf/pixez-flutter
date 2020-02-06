import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pixez/component/illust_card.dart';
import 'package:pixez/page/user/bookmark/bloc.dart';
import 'package:pixez/page/user/bookmark/tag/user_bookmark_tag_page.dart';

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
  String tags = null;

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
                    itemCount: state.illusts.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0)
                        return ListTile(
                          contentPadding: EdgeInsets.all(0),
                          trailing: IconButton(
                            icon: Icon(Icons.sort),
                            onPressed: () async {
                              /*  BlocProvider.of<BookmarkBloc>(context)
                            .add(FetchBookmarkEvent(widget.id, widget.restrict,tags: ''));*/
                              final result = await Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (_) => UserBookmarkTagPage()));
                              if (result != null) {
                                tags = result;
                                _easyRefreshController.callRefresh();
                              }
                            },
                          ),
                        );
                      return IllustCard(state.illusts[index - 1]);
                    },
                    staggeredTileBuilder: (int index) =>
                        StaggeredTile.fit(index == 0 ? 2 : 1),
                  )
                : Container(),
            onRefresh: () async {
              BlocProvider.of<BookmarkBloc>(context).add(
                  FetchBookmarkEvent(widget.id, widget.restrict, tags: tags));
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
