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

import 'package:bot_toast/bot_toast.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/component/comment_emoji_text.dart';
import 'package:pixez/component/pixez_default_header.dart';
import 'package:pixez/fluent/component/painter_avatar.dart';
import 'package:pixez/fluent/component/pixiv_image.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/exts.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/comment_response.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/comment/comment_page.dart';
import 'package:pixez/page/comment/comment_store.dart';
import 'package:pixez/fluent/page/report/report_items_page.dart';

class CommentPage extends StatefulWidget {
  final int id;
  final bool isReplay;
  final int? pId;
  final String? name;
  final CommentArtWorkType type;

  const CommentPage(
      {Key? key,
      required this.id,
      this.isReplay = false,
      this.pId,
      this.name,
      this.type = CommentArtWorkType.ILLUST})
      : super(key: key);

  @override
  _CommentPageState createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  late TextEditingController _editController;
  int? parentCommentId;
  String? parentCommentName;
  late EasyRefreshController easyRefreshController;
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
    easyRefreshController = EasyRefreshController(
        controlFinishLoad: true, controlFinishRefresh: true);
    _store = CommentStore(easyRefreshController, widget.id, widget.pId,
        widget.isReplay, widget.type)
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
              child: IconButton(
                onPressed: () {
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
                icon: Image.asset(
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

  bool commentHateByUser(Comment comment) {
    for (var i in muteStore.banComments) {
      if (i.commentId == comment.id.toString()) {
        return true;
      }
    }
    for (var i in muteStore.banUserIds) {
      if (i.userId == comment.user?.id?.toString()) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: PageHeader(
        title: Text(I18n.of(context).view_comment),
      ),
      content: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: EasyRefresh(
                header: PixezDefault.header(context),
                controller: easyRefreshController,
                onRefresh: () => _store.fetch(),
                onLoad: () => _store.next(),
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
                                style:
                                    FluentTheme.of(context).typography.title),
                          ),
                        ),
                      );
                    }
                    var comments = _store.comments
                        .where((element) => !commentHateByUser(element))
                        .toList();
                    return comments.isNotEmpty
                        ? ListView.separated(
                            itemCount: comments.length,
                            padding: EdgeInsets.only(top: 10),
                            itemBuilder: (context, index) {
                              if (banList
                                  .where((element) => comments[index]
                                      .comment!
                                      .contains(element))
                                  .isNotEmpty)
                                return Visibility(
                                  visible: false,
                                  child: Container(),
                                );
                              var comment = comments[index];
                              return Container(
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: PainterAvatar(
                                        url: comments[index]
                                            .user!
                                            .profileImageUrls
                                            .medium,
                                        id: comments[index].user!.id!,
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
                                                style: TextStyle(
                                                    color:
                                                        FluentTheme.of(context)
                                                            .accentColor,
                                                    overflow:
                                                        TextOverflow.ellipsis),
                                              ),
                                              _buildTrailingRow(
                                                  comment, context)
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
                                              child: Button(
                                                child: Text(I18n.of(context)
                                                    .view_replies),
                                                onPressed: () async {
                                                  Leader.push(
                                                    context,
                                                    CommentPage(
                                                      id: widget.id,
                                                      isReplay: true,
                                                      pId: comment.id!,
                                                      type: widget.type,
                                                      name: comment.user!.name,
                                                    ),
                                                    icon: Icon(
                                                        FluentIcons.comment),
                                                    title: Text(I18n.of(context)
                                                        .view_comment),
                                                  );
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
                                              style: FluentTheme.of(context)
                                                  .typography
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
                                  .where((element) => comments[index]
                                      .comment!
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
                              child: ProgressRing(),
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
                    color: FluentTheme.of(context).scaffoldBackgroundColor,
                    child: Row(
                      children: <Widget>[
                        IconButton(
                          icon: Icon(FluentIcons.book_answers),
                          onPressed: () {
                            if (widget.isReplay) return;
                            setState(() {
                              parentCommentName = null;
                              parentCommentId = null;
                            });
                          },
                        ),
                        IconButton(
                          icon: Icon(FluentIcons.emoji),
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
                              padding: const EdgeInsets.only(
                                  bottom: 2.0, right: 8.0),
                              child: InfoLabel(
                                label:
                                    "Reply to ${parentCommentName == null ? "illust" : parentCommentName}",
                                child: TextBox(
                                    controller: _editController,
                                    suffix: IconButton(
                                        icon: Icon(
                                          FluentIcons.reply,
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
                                                  .isEmpty) if (widget
                                                      .type ==
                                                  CommentArtWorkType.ILLUST)
                                                await client.postIllustComment(
                                                    widget.id, txt,
                                                    parent_comment_id:
                                                        parentCommentId);
                                              else if (widget.type ==
                                                  CommentArtWorkType.NOVEL)
                                                await client.postNovelComment(
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
                              )),
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

  Widget _buildTrailingRow(Comment comment, BuildContext context) {
    FlyoutController controller = FlyoutController();
    return Row(
      children: [
        IconButton(
            onPressed: () {
              if (widget.isReplay) return;
              parentCommentId = comment.id;
              setState(() {
                parentCommentName = comment.user!.name;
              });
            },
            icon: Text(
              widget.isReplay ? "" : "Reply",
              style: TextStyle(color: FluentTheme.of(context).accentColor),
            )),
        if (!widget.isReplay)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: FlyoutTarget(
              controller: controller,
              child: IconButton(
                onPressed: () => controller.showFlyout(
                  placementMode: FlyoutPlacementMode.bottomCenter,
                  builder: (context) => MenuFlyout(
                    items: [
                      MenuFlyoutItem(
                        text: Text(I18n.of(context).ban),
                        onPressed: () async {
                          await muteStore.insertComment(comment);
                        },
                      ),
                      MenuFlyoutItem(
                        text: Text(I18n.of(context).report),
                        onPressed: () {
                          Reporter.show(
                            context,
                            () async => await muteStore.insertComment(comment),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                icon: Icon(FluentIcons.more),
              ),
            ),
          )
      ],
    );
  }
}
