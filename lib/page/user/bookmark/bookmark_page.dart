import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pixez/bloc/account_bloc.dart';
import 'package:pixez/bloc/account_state.dart';
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
  EasyRefreshController _easyRefreshController;
  String tags;
  String restrict;

  @override
  void initState() {
    restrict = widget.restrict;
    super.initState();
    _easyRefreshController = EasyRefreshController();
  }

  @override
  Widget build(BuildContext context) {
    AccountState accountState = BlocProvider.of<AccountBloc>(context).state;
    return BlocListener<BookmarkBloc, BookmarkState>(
      listener: (context, state) {
        if (state is SuccessRefreshState) {
          _easyRefreshController.finishRefresh(success: true);
        }
        if (state is LoadMoreSuccessState) {
          _easyRefreshController.finishLoad(success: true);
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
        condition: (pre, now) => now is DataBookmarkState,
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
                  return accountState is HasUserState &&
                      int.parse(accountState.list.userId) == widget.id ?
                  ListTile(
                    leading: Text(state.tag ?? ""),
                    trailing: IconButton(
                      icon: Icon(Icons.sort),
                      onPressed: () async {
                        final result = await Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => UserBookmarkTagPage()));
                        if (result != null) {
                          restrict = result['restrict'];
                          var tag = result['tag'];
                          _easyRefreshController.resetRefreshState();
                          BlocProvider.of<BookmarkBloc>(context).add(
                              FetchBookmarkEvent(widget.id, restrict,
                                  tags: tag));
                        }
                      },
                    ),
                  ) : Visibility(visible: false, child: Container());
                return IllustCard(state.illusts[index - 1]);
              },
              staggeredTileBuilder: (int index) =>
                  StaggeredTile.fit(index == 0 ? 2 : 1),
            )
                : Container(),
            onRefresh: () async {
              BlocProvider.of<BookmarkBloc>(context).add(FetchBookmarkEvent(
                  widget.id, restrict,
                  tags: state is DataBookmarkState ? state.tag : null));
              return;
            },
            onLoad: () async {
              if (state is DataBookmarkState) {
                BlocProvider.of<BookmarkBloc>(context)
                    .add(LoadMoreEvent(state.nextUrl, state.illusts));
                return;
              }
              return;
            },
          );
        },
      ),
    );
  }
}
