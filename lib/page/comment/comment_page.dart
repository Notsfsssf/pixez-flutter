import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:pixez/component/painter_avatar.dart';
import 'package:pixez/generated/i18n.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/comment/bloc/bloc.dart';

class CommentPage extends StatelessWidget {
  final int id;

  const CommentPage({Key key, this.id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    EasyRefreshController easyRefreshController = EasyRefreshController();
    Completer<void> _refreshCompleter, _loadCompleter = Completer();
    return BlocProvider<CommentBloc>(
      child: BlocListener<CommentBloc, CommentState>(
        child: BlocBuilder<CommentBloc, CommentState>(
          builder: (BuildContext context, CommentState state) {
            if (state is DataCommentState) {
              var comments = state.commentResponse.comments;
              return Scaffold(
                appBar: AppBar(
                  title: Text(I18n.of(context).View_Comment),
                ),
                body: EasyRefresh(
                  controller: easyRefreshController,
                  onLoad: () {
                    BlocProvider.of<CommentBloc>(context)
                        .add(LoadMoreCommentEvent(state.commentResponse));
                    return _loadCompleter.future;
                  },
                  child: ListView.builder(
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        var comment = comments[index];
                        return ListTile(
                          leading: PainterAvatar(
                            url: comments[index].user.profileImageUrls.medium,
                            id: comments[index].user.id,
                          ),
                          title: Text(comment.user.name),
                          subtitle: SelectableText(comment.comment),
                        );
                      }),
                ),
              );
            }
            return Scaffold(appBar: AppBar(), body: Container());
          },
        ),
        listener: (BuildContext context, CommentState state) {
          if (state is DataCommentState) {
            _loadCompleter?.complete();
            _loadCompleter = Completer();
            _refreshCompleter?.complete();
            _refreshCompleter = Completer();
          }
        },
      ),
      create: (BuildContext context) => CommentBloc(
          RepositoryProvider.of<ApiClient>(context), easyRefreshController)
        ..add(FetchCommentEvent(id)),
    );
  }
}
