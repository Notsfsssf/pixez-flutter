import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_easyrefresh/material_header.dart';

import 'package:pixez/component/painer_card.dart';
import 'package:pixez/generated/l10n.dart';
import 'package:pixez/models/user_preview.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/hello/new/painter/bloc/bloc.dart';

class NewPainterPage extends StatefulWidget {
  final int id;

  final String restrict;

  const NewPainterPage({Key key, @required this.id, this.restrict = 'public'})
      : super(key: key);

  @override
  _NewPainterPageState createState() => _NewPainterPageState();
}

class _NewPainterPageState extends State<NewPainterPage>
    with AutomaticKeepAliveClientMixin {
  Completer<void> _refreshCompleter, _loadCompleter;
  EasyRefreshController _refreshController;
  ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _refreshCompleter = Completer<void>();
    _loadCompleter = Completer<void>();
    _refreshController = EasyRefreshController();
  }

  @override
  void dispose() {
    _refreshController?.dispose();
    _scrollController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<NewPainterBloc>(
      create: (BuildContext context) {
        return NewPainterBloc(RepositoryProvider.of<ApiClient>(context))
          ..add(FetchPainterEvent(widget.id, widget.restrict));
      },
      child: MultiBlocListener(
        listeners: [
          BlocListener<NewPainterBloc, NewPainterState>(
              listener: (context, state) {
            if (state is DataState) {
              _loadCompleter?.complete();
              _loadCompleter = Completer();
              _refreshCompleter?.complete();
              _refreshCompleter = Completer();
            }
            if (state is LoadEndState) {
              _loadCompleter?.complete();
              _loadCompleter = Completer();
              _refreshCompleter?.complete();
              _refreshCompleter = Completer();
              _refreshController.finishLoad(
                success: true,
                noMore: true,
              );
            }
            if (state is FailState) {
              _loadCompleter?.complete();
              _loadCompleter = Completer();
              _refreshCompleter?.complete();
              _refreshCompleter = Completer();
              _refreshController.finishRefresh(success: false);
            }
          }),
        ],
        child: BlocBuilder<NewPainterBloc, NewPainterState>(
          condition: (pre, now) {
            return now is DataState;
          },
          builder: (context, state) {
            return EasyRefresh(
              controller: _refreshController,
              firstRefresh: true,
              header: MaterialHeader(),
              onRefresh: () {
                BlocProvider.of<NewPainterBloc>(context)
                    .add(FetchPainterEvent(widget.id, widget.restrict));
                return _refreshCompleter.future;
              },
              onLoad: () {
                if (state is DataState) {
                  BlocProvider.of<NewPainterBloc>(context)
                      .add(LoadMoreEvent(state.nextUrl, state.users));
                  return _loadCompleter.future;
                }
                return null;
              },
              child: state is DataState
                  ? ListView.builder(
                controller: _scrollController,
                itemCount: state.users.length+1,
                itemBuilder: (BuildContext context, int index) {
                  if(index==0){
                    return   Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(icon: Icon(Icons.list), onPressed: (){
                        showModalBottomSheet(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                            ),
                            context: context,
                            builder: (context1) => Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                ListTile(
                                  title: Text(I18n.of(context).public),
                                  onTap: () {
                                    Navigator.of(context1).pop();
                                    BlocProvider.of<NewPainterBloc>(context).add(FetchPainterEvent(widget.id, 'public'));
                                  },
                                ),
                                ListTile(
                                  title: Text(I18n.of(context).private),
                                  onTap: () {
                                    Navigator.of(context1).pop();
                                    BlocProvider.of<NewPainterBloc>(context).add(FetchPainterEvent(widget.id, 'private'));
                                  },
                                ),
                              ],
                            ));
                      }),
                    );
                  }
                  UserPreviews user = state.users[index-1];
                  return PainterCard(
                    user: user,
                  );
                },
              )
                  : Container(),
            );
          },
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
