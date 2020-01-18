import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:pixez/component/painter_avatar.dart';
import 'package:pixez/generated/i18n.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/comment/bloc/bloc.dart';

class CommentPage extends StatefulWidget {
  final int id;

  const CommentPage({Key key, this.id}) : super(key: key);

  @override
  _CommentPageState createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  TextEditingController _editController;
  int parent_comment_id = null;
  String parentCommentName = null;
  EasyRefreshController easyRefreshController;
  Completer<void> _refreshCompleter, _loadCompleter = Completer();

  @override
  void initState() {
    super.initState();
    _editController = TextEditingController();
    easyRefreshController = EasyRefreshController();
  }

  @override
  void dispose() {
    super.dispose();
    _editController.dispose();
    easyRefreshController.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                body: SafeArea(
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        child: EasyRefresh(
                          controller: easyRefreshController,
                          onLoad: () {
                            BlocProvider.of<CommentBloc>(context)
                                .add(LoadMoreCommentEvent(state.commentResponse));
                            return _loadCompleter.future;
                          },
                          child: ListView.builder(
                            shrinkWrap: true,
                              itemCount: comments.length,
                              itemBuilder: (context, index) {
                                var comment = comments[index];
                                return ListTile(
                                  leading: PainterAvatar(
                                    url: comments[index]
                                        .user
                                        .profileImageUrls
                                        .medium,
                                    id: comments[index].user.id,
                                  ),
                                  title: Flex(
                                    direction: Axis.horizontal,
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Expanded(
                                        child: Text(
                                          comment.user.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      FlatButton(
                                          onPressed: () {
                                            parent_comment_id = comment.id;
                                            setState(() {
                                              parentCommentName = comment.user.name;
                                            });
                                          },
                                          child: Text(
                                            "Reply",
                                            style: TextStyle(
                                                color:
                                                    Theme.of(context).primaryColor),
                                          ))
                                    ],
                                  ),
                                  subtitle: SelectableText(comment.comment),
                                );
                              }),
                        ),
                      ),
                      Container(
                        color: Theme.of(context).dialogBackgroundColor,
                        padding: EdgeInsets.only(left: 2.0, right: 2.0),
                        child: TextField(
                          controller: _editController,
                          decoration: InputDecoration(
                              labelText:
                                  "Reply to ${parentCommentName == null ? "illust" : parentCommentName}",
                              suffixIcon: IconButton(
                                  icon: Icon(Icons.reply),
                                  onPressed: () async {
                                    final client =
                                        RepositoryProvider.of<ApiClient>(
                                            context);
                                    String txt = _editController.text.trim();
                                    try {
                                      if (txt.isNotEmpty)
                                        Response reponse = await client
                                            .postIllustComment(widget.id, txt,
                                                parent_comment_id:
                                                    parent_comment_id);
                                      _editController.clear();
                                      BlocProvider.of<CommentBloc>(context)
                                          .add(FetchCommentEvent(widget.id));
                                    } catch (e) {
                                      print(e);
                                    }
                                  })),
                        ),
                      )
                    ],
                  ),
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
      create: (BuildContext context) =>
      CommentBloc(
          RepositoryProvider.of<ApiClient>(context), easyRefreshController)
        ..add(FetchCommentEvent(widget.id)),
    );
  }
}
