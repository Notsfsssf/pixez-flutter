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

import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/component/comment_emoji_text.dart';
import 'package:pixez/component/painter_avatar.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/exts.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/models/comment_response.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/comment/comment_store.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class CommentPage extends StatefulWidget {
  final int id;
  final bool isReplay;
  final int? pId;
  final String? name;

  const CommentPage(
      {Key? key, required this.id, this.isReplay = false, this.pId, this.name})
      : super(key: key);

  @override
  _CommentPageState createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  late TextEditingController _editController;
  int? parentCommentId;
  String? parentCommentName;
  late RefreshController easyRefreshController;
  late CommentStore _store;

  List<String> banList = [
    "bb8.news",
    "77k.live",
    "7mm.live",
    "p26w.com",
    "33h.live"
  ];

  @override
  void initState() {
    parentCommentId = widget.isReplay ? widget.pId : null;
    parentCommentName = widget.isReplay ? widget.name : null;
    _editController = TextEditingController();
    easyRefreshController = RefreshController();
    _store = CommentStore(
        easyRefreshController, widget.id, widget.pId, widget.isReplay)
      ..fetch();
    super.initState();
  }

  @override
  void dispose() {
    _editController.dispose();
    easyRefreshController.dispose();
    super.dispose();
  }

  bool _emojiPanelShow = false;

  Widget _buildEmojiPanel(BuildContext context) {
    return Container(
      height: 200,
      child: GridView.count(
        crossAxisCount: 5,
        children: [
          for (var i in emojisMap.keys)
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: InkWell(
                onTap: () {
                  String key = i;
                  String text = _editController.text;
                  TextSelection textSelection = _editController.selection;
                  if (!textSelection.isValid) {
                    _editController.text = "${_editController.text}${key}";
                    return;
                  }
                  String newText = text.replaceRange(
                      textSelection.start, textSelection.end, key);
                  final emojiLength = key.length;
                  _editController.text = newText;
                  _editController.selection = textSelection.copyWith(
                    baseOffset: textSelection.start + emojiLength,
                    extentOffset: textSelection.start + emojiLength,
                  );
                },
                child: Image.asset(
                  'assets/emojis/${emojisMap[i]}',
                  width: 32,
                  height: 32,
                ),
              ),
            )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(I18n.of(context).view_comment),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: SmartRefresher(
                controller: easyRefreshController,
                enablePullUp: true,
                enablePullDown: true,
                header: (Platform.isAndroid)
                    ? MaterialClassicHeader(
                        color: Theme.of(context).colorScheme.secondary,
                        backgroundColor: Theme.of(context).cardColor,
                      )
                    : ClassicHeader(),
                onRefresh: () => _store.fetch(),
                onLoading: () => _store.next(),
                child: Observer(
                  builder: (context) {
                    if (_store.errorMessage != null) {
                      return Container(
                        child: Center(
                          child: Text(_store.errorMessage!),
                        ),
                      );
                    }
                    if (_store.isEmpty) {
                      return Container(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('[ ]',
                                style: Theme.of(context).textTheme.headline4),
                          ),
                        ),
                      );
                    }
                    return _store.comments.isNotEmpty
                        ? ListView.separated(
                            itemCount: _store.comments.length,
                            itemBuilder: (context, index) {
                              if (banList
                                  .where((element) => _store
                                      .comments[index].comment!
                                      .contains(element))
                                  .isNotEmpty)
                                return Visibility(
                                  visible: false,
                                  child: Container(),
                                );
                              var comment = _store.comments[index];
                              return Container(
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: PainterAvatar(
                                        url: _store.comments[index].user!
                                            .profileImageUrls.medium,
                                        id: _store.comments[index].user!.id!,
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.max,
                                        children: <Widget>[
                                          Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Text(
                                                comment.user!.name,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .secondary),
                                              ),
                                              TextButton(
                                                  onPressed: () {
                                                    if (widget.isReplay) return;
                                                    parentCommentId =
                                                        comment.id;
                                                    setState(() {
                                                      parentCommentName =
                                                          comment.user!.name;
                                                    });
                                                  },
                                                  child: Text(
                                                    widget.isReplay
                                                        ? ""
                                                        : "Reply",
                                                    style: TextStyle(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .secondary),
                                                  ))
                                            ],
                                          ),
                                          if (comment.parentComment?.user !=
                                              null)
                                            Text(
                                                'To ${comment.parentComment!.user!.name}'),
                                          if (comment.stamp == null)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 4.0),
                                              child: CommentEmojiText(
                                                text: comment.comment ?? "",
                                              ),
                                            ),
                                          if (comment.stamp != null)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 4.0),
                                              child: PixivImage(
                                                comment.stamp!.stamp_url!,
                                                height: 100,
                                                width: 100,
                                              ),
                                            ),
                                          if (comment.hasReplies == true)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 4.0),
                                              child: ActionChip(
                                                label: Text(I18n.of(context)
                                                    .view_replies),
                                                onPressed: () async {
                                                  Leader.push(
                                                      context,
                                                      CommentPage(
                                                        id: widget.id,
                                                        isReplay: true,
                                                        pId: comment.id!,
                                                        name:
                                                            comment.user!.name,
                                                      ));
                                                },
                                              ),
                                            ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8.0),
                                            child: Text(
                                              comment.date
                                                  .toString()
                                                  .toShortTime(),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .caption,
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              );
                            },
                            separatorBuilder:
                                (BuildContext context, int index) {
                              if (banList
                                  .where((element) => _store
                                      .comments[index].comment!
                                      .contains(element))
                                  .isNotEmpty)
                                return Visibility(
                                  visible: false,
                                  child: Container(),
                                );
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Divider(),
                              );
                            },
                          )
                        : Container(
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          );
                  },
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                children: [
                  Container(
                    color: Theme.of(context).dialogBackgroundColor,
                    child: Row(
                      children: <Widget>[
                        IconButton(
                          icon: Icon(Icons.book),
                          onPressed: () {
                            if (widget.isReplay) return;
                            setState(() {
                              parentCommentName = null;
                              parentCommentId = null;
                            });
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.emoji_emotions_outlined),
                          onPressed: () {
                            setState(() {
                              _emojiPanelShow = !_emojiPanelShow;
                              if (_emojiPanelShow) {
                                FocusScope.of(context).unfocus();
                              }
                            });
                          },
                        ),
                        Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.only(bottom: 2.0, right: 8.0),
                            child: Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: Theme.of(context)
                                    .colorScheme
                                    .copyWith(
                                        primary: Theme.of(context)
                                            .colorScheme
                                            .secondary),
                              ),
                              child: TextField(
                                controller: _editController,
                                decoration: InputDecoration(
                                    labelText:
                                        "Reply to ${parentCommentName == null ? "illust" : parentCommentName}",
                                    suffixIcon: IconButton(
                                        icon: Icon(
                                          Icons.reply,
                                        ),
                                        onPressed: () async {
                                          final client = apiClient;
                                          String txt =
                                              _editController.text.trim();
                                          final fun1 = BotToast.showLoading();
                                          try {
                                            if (txt.isNotEmpty) {
                                              if (banList
                                                  .where((element) =>
                                                      txt.contains(element))
                                                  .isEmpty)
                                                await client.postIllustComment(
                                                    widget.id, txt,
                                                    parent_comment_id:
                                                        parentCommentId);
                                            }
                                            _editController.clear();
                                            _store.fetch();
                                          } catch (e) {
                                            print(e);
                                          }
                                          fun1();
                                        })),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (MediaQuery.of(context).viewInsets.bottom == 0 &&
                      _emojiPanelShow)
                    _buildEmojiPanel(context),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
