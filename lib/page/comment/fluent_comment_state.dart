import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/component/comment_emoji_text.dart';
import 'package:pixez/component/painter_avatar.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/exts.dart';
import 'package:pixez/component/fluent/fluent_ink_well.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/comment/comment_page.dart';
import 'package:pixez/page/comment/comment_store.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class FluentCommentPageState extends CommentPageStateBase {
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
                  String text = editController.text;
                  TextSelection textSelection = editController.selection;
                  if (!textSelection.isValid) {
                    editController.text = "${editController.text}${key}";
                    return;
                  }
                  String newText = text.replaceRange(
                      textSelection.start, textSelection.end, key);
                  final emojiLength = key.length;
                  editController.text = newText;
                  editController.selection = textSelection.copyWith(
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
    return SafeArea(
      child: Column(
        children: <Widget>[
          Expanded(
            child: SmartRefresher(
              controller: easyRefreshController,
              enablePullUp: true,
              enablePullDown: true,
              header: (Platform.isAndroid)
                  ? MaterialClassicHeader(
                      color: FluentTheme.of(context).accentColor,
                      backgroundColor: FluentTheme.of(context).cardColor,
                    )
                  : ClassicHeader(),
              onRefresh: () => store.fetch(),
              onLoading: () => store.next(),
              child: Observer(
                builder: (context) {
                  if (store.errorMessage != null) {
                    return Container(
                      child: Center(
                        child: Text(store.errorMessage!),
                      ),
                    );
                  }
                  if (store.isEmpty) {
                    return Container(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('[ ]',
                              style:
                                  FluentTheme.of(context).typography.caption),
                        ),
                      ),
                    );
                  }
                  return store.comments.isNotEmpty
                      ? ListView.separated(
                          itemCount: store.comments.length,
                          itemBuilder: (context, index) {
                            if (banList
                                .where((element) => store
                                    .comments[index].comment!
                                    .contains(element))
                                .isNotEmpty)
                              return Visibility(
                                visible: false,
                                child: Container(),
                              );
                            var comment = store.comments[index];
                            return Container(
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: PainterAvatar(
                                      url: store.comments[index].user!
                                          .profileImageUrls.medium,
                                      id: store.comments[index].user!.id!,
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
                                                  color: FluentTheme.of(context)
                                                      .accentColor),
                                            ),
                                            TextButton(
                                                onPressed: () {
                                                  if (widget.isReplay) return;
                                                  parentCommentId = comment.id;
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
                                                      color: FluentTheme.of(
                                                              context)
                                                          .accentColor),
                                                ))
                                          ],
                                        ),
                                        if (comment.parentComment?.user != null)
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
                                            child: Chip(
                                              text: Text(I18n.of(context)
                                                  .view_replies),
                                              onPressed: () async {
                                                // TODO: Leader.fluentNav
                                                Leader.push(
                                                    context,
                                                    CommentPage(
                                                      id: widget.id,
                                                      isReplay: true,
                                                      pId: comment.id!,
                                                      type: widget.type,
                                                      name: comment.user!.name,
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
                          separatorBuilder: (BuildContext context, int index) {
                            if (banList
                                .where((element) => store
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
                          padding:
                              const EdgeInsets.only(bottom: 2.0, right: 8.0),
                          child: AutoSuggestBox(
                            placeholder:
                                "Reply to ${parentCommentName == null ? "illust" : parentCommentName}",
                            controller: editController,
                            items: [],
                            trailingIcon: IconButton(
                              icon: Icon(
                                FluentIcons.reply,
                              ),
                              onPressed: () async {
                                final client = apiClient;
                                String txt = editController.text.trim();
                                final fun1 = BotToast.showLoading();
                                try {
                                  if (txt.isNotEmpty) {
                                    if (banList
                                        .where(
                                            (element) => txt.contains(element))
                                        .isEmpty) if (widget
                                            .type ==
                                        CommentArtWorkType.ILLUST)
                                      await client.postIllustComment(
                                          widget.id, txt,
                                          parent_comment_id: parentCommentId);
                                    else if (widget.type ==
                                        CommentArtWorkType.NOVEL)
                                      await client.postNovelComment(
                                          widget.id, txt,
                                          parent_comment_id: parentCommentId);
                                  }
                                  editController.clear();
                                  store.fetch();
                                } catch (e) {
                                  print(e);
                                }
                                fun1();
                              },
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
    );
  }
}
