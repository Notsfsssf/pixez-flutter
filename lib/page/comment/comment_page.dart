/*
 * Copyright (C) 2020. by perol_notsf, All rights reserved
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program. If not, see <http://www.gnu.org/licenses/>.
 *
 */

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_easyrefresh/material_header.dart';
import 'package:pixez/component/painter_avatar.dart';
import 'package:pixez/generated/l10n.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/comment/comment_store.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class CommentPage extends StatefulWidget {
  final int id;

  const CommentPage({Key key, this.id}) : super(key: key);

  @override
  _CommentPageState createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  TextEditingController _editController;
  int parentCommentId;
  String parentCommentName;
  EasyRefreshController easyRefreshController;
  CommentStore _store;
  String toShortTime(String dateString) {
    try {
      var formatter = new DateFormat('yyyy-MM-dd HH:mm:ss');
      return formatter.format(DateTime.parse(dateString));
    } catch (e) {
      return dateString;
    }
  }
  @override
  void initState() {
    _editController = TextEditingController();
    easyRefreshController = EasyRefreshController();
    _store = CommentStore(easyRefreshController, widget.id);
    super.initState();
  }

  @override
  void dispose() {
    _editController?.dispose();
    easyRefreshController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
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
                    enableControlFinishLoad: true,
                    enableControlFinishRefresh: true,
                    firstRefresh: true,
                    onRefresh: () => _store.fetch(),
                    header: MaterialHeader(),
                    onLoad: () => _store.next(),
                    child: _store.comments.isNotEmpty
                        ? ListView.builder(
                            shrinkWrap: true,
                            itemCount: _store.comments.length,
                            itemBuilder: (context, index) {
                              var comment = _store.comments[index];
                              return ListTile(
                                leading: PainterAvatar(
                                  url: _store
                                      .comments[index].user.profileImageUrls.medium,
                                  id: _store.comments[index].user.id,
                                ),
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text(
                                          comment.user.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        FlatButton(
                                            onPressed: () {
                                              parentCommentId = comment.id;
                                              setState(() {
                                                parentCommentName =
                                                    comment.user.name;
                                              });
                                            },
                                            child: Text(
                                              "Reply",
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .primaryColor),
                                            ))
                                      ],
                                    ),
                                    ...comment.parentComment.user != null
                                        ? [
                                            Text(
                                                'To ${comment.parentComment.user.name}')
                                          ]
                                        : []
                                  ],
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                  SelectableText(comment.comment),
                                  Padding(
                                    padding: const EdgeInsets.only(top:8.0),
                                    child: Text(toShortTime(comment.date.toString())),
                                  )
                                ],),
                              );
                            })
                        : Container(),
                  ),
                ),
                Container(
                  color: Theme.of(context).dialogBackgroundColor,
                  child: Row(
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.book),
                        onPressed: () {
                          setState(() {
                            parentCommentName = null;
                            parentCommentId = null;
                          });
                        },
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 2.0, right: 8.0),
                          child: TextField(
                            controller: _editController,
                            decoration: InputDecoration(
                                labelText:
                                    "Reply to ${parentCommentName == null ? "illust" : parentCommentName}",
                                suffixIcon: IconButton(
                                    icon: Icon(Icons.reply),
                                    onPressed: () async {
                                      final client = apiClient;
                                      String txt = _editController.text.trim();
                                      try {
                                        if (txt.isNotEmpty)
                                          Response reponse = await client
                                              .postIllustComment(widget.id, txt,
                                                  parent_comment_id:
                                                      parentCommentId);
                                        _editController.clear();
                                        _store.fetch();
                                      } catch (e) {
                                        print(e);
                                      }
                                    })),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      }
    );
  }
}
