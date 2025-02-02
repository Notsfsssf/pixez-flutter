import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/component/selectable_html.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/exts.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/ban_tag.dart';
import 'package:pixez/models/illust.dart';
import 'package:pixez/page/comment/comment_page.dart';
import 'package:pixez/page/picture/illust_store.dart';
import 'package:pixez/page/picture/user_follow_button.dart';
import 'package:pixez/page/search/result_page.dart';
import 'package:pixez/page/series/illust_series_page.dart';
import 'package:pixez/page/user/user_store.dart';
import 'package:pixez/page/user/users_page.dart';
import 'package:pixez/supportor_plugin.dart';
import 'package:pixez/component/painter_avatar.dart';
import 'package:share_plus/share_plus.dart';

class IllustDetailContent extends StatefulWidget {
  final Illusts illusts;
  final UserStore? userStore;
  final IllustStore? illustStore;
  final VoidCallback loadAbout;
  const IllustDetailContent({
    super.key,
    required this.illusts,
    this.userStore,
    this.illustStore,
    required this.loadAbout,
  });

  @override
  State<IllustDetailContent> createState() => _IllustDetailContentState();
}

class _IllustDetailContentState extends State<IllustDetailContent> {
  late Illusts _illusts;

  late UserStore? userStore;
  late FocusNode _focusNode;
  late IllustStore? _illustStore;
  String _selectedText = "";

  @override
  void initState() {
    _focusNode = FocusNode();
    _illusts = widget.illusts;
    _illustStore = widget.illustStore;
    userStore = widget.userStore;
    super.initState();
    supportTranslateCheck();
    widget.loadAbout();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant IllustDetailContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.illusts.caption.isNotEmpty &&
        widget.illusts.caption != oldWidget.illusts.caption) {
      setState(() {
        _illusts = widget.illusts;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildInfoArea(context, _illusts),
          _buildNameAvatar(context, _illusts),
          _buildTagArea(context, _illusts),
          _buildCaptionArea(_illusts),
          _buildCommentTextArea(context, _illusts),
          Padding(
            padding:
                const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 4.0),
            child: Text(I18n.of(context).about_picture),
          )
        ],
      );
    });
  }

  Widget _buildInfoArea(BuildContext context, Illusts data) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 8.0,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: SelectionArea(
              child: Text(
                data.title,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(fontSize: 18),
              ),
            ),
          ),
          if (data.series != null)
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => IllustSeriesPage(
                          id: data.series!.id,
                        )));
              },
              behavior: HitTestBehavior.opaque,
              child: Container(
                  margin: EdgeInsets.only(left: 0, bottom: 0),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${data.series?.title ?? ''}',
                    style: Theme.of(context).textTheme.bodySmall,
                  )),
            ),
          SizedBox(
            height: 8.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Icon(
                Icons.remove_red_eye,
                color: Theme.of(context).colorScheme.onSurface,
                size: 12,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 2.0),
                child: Text(
                  data.totalView.toString(),
                  style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurface),
                ),
              ),
              Container(
                width: 4.0,
              ),
              Icon(
                Icons.favorite,
                color: Theme.of(context).colorScheme.onSurface,
                size: 12.0,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 2.0),
                child: Text("${data.totalBookmarks}",
                    style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurface)),
              ),
              Container(
                width: 4.0,
              ),
              Icon(
                Icons.timelapse_rounded,
                color: Theme.of(context).colorScheme.onSurface,
                size: 12.0,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 2.0),
                child: Text(data.createDate.toShortTime(),
                    style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurface)),
              )
            ],
          ),
          SizedBox(
            height: 8,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                  child: Text(
                I18n.of(context).illust_id,
                style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface),
              )),
              Container(
                width: 4.0,
              ),
              colorText(data.id.toString(), context),
              Container(
                width: 10.0,
              ),
              Container(
                  child: Text(
                I18n.of(context).pixel,
                style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface),
              )),
              Container(
                width: 4.0,
              ),
              colorText("${data.width}x${data.height}", context)
            ],
          ),
          SizedBox(
            height: 8,
          ),
        ],
      ),
    );
  }

  Widget colorText(String text, BuildContext context) {
    return SelectionArea(
      child: Text(
        text,
        style: TextStyle(
            color: Theme.of(context).colorScheme.secondary, fontSize: 12),
      ),
    );
  }

  Padding _buildTagArea(BuildContext context, Illusts data) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 6,
        runSpacing: 6,
        children: [
          if (data.illustAIType == 2)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: const BorderRadius.all(Radius.circular(8)),
              ),
              child: RichText(
                  textAlign: TextAlign.start,
                  text: TextSpan(
                      text: "${I18n.of(context).ai_generated}",
                      children: [
                        TextSpan(
                          text: " ",
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall!
                              .copyWith(fontSize: 12),
                        ),
                      ],
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall!
                          .copyWith(color: Colors.white, fontSize: 12))),
            ),
          for (var f in data.tags) buildRow(context, f)
        ],
      ),
    );
  }

  Widget _buildCaptionArea(Illusts data) {
    final caption = data.caption.isEmpty
        ? _illustStore?.illusts?.caption ?? ""
        : data.caption;
    if (caption.isEmpty && _illustStore?.captionFetchError == true) {
      return Container(
        margin: EdgeInsets.only(top: 4),
        child: Container(
          child: Center(
            child: InkWell(
                onTap: () {
                  _illustStore?.fetch();
                },
                child: Icon(Icons.refresh)),
          ),
        ),
      );
    }
    if (caption.isEmpty && _illustStore?.captionFetching == true) {
      return Container(
          child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: CircularProgressIndicator(),
        ),
      ));
    }
    if (caption.isEmpty) {
      return Container(height: 1);
    }
    return Container(
      margin: EdgeInsets.only(top: 4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 14),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onInverseSurface,
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            child: Container(
              width: double.infinity,
              child: SelectionArea(
                focusNode: _focusNode,
                onSelectionChanged: (value) {
                  _selectedText = value?.plainText ?? "";
                },
                contextMenuBuilder: (context, selectableRegionState) {
                  return _buildSelectionMenu(selectableRegionState, context);
                },
                child: SelectableHtml(
                  data: caption.isEmpty ? "~" : caption,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool supportTranslate = false;

  AdaptiveTextSelectionToolbar _buildSelectionMenu(
      SelectableRegionState editableTextState, BuildContext context) {
    final List<ContextMenuButtonItem> buttonItems =
        editableTextState.contextMenuButtonItems;
    if (supportTranslate) {
      buttonItems.insert(
        buttonItems.length,
        ContextMenuButtonItem(
          label: I18n.of(context).translate,
          onPressed: () async {
            final selectionText = _selectedText;
            if (Platform.isIOS) {
              final box = context.findRenderObject() as RenderBox?;
              final pos = box != null
                  ? box.localToGlobal(Offset.zero) & box.size
                  : null;
              Share.share(selectionText, sharePositionOrigin: pos);
              return;
            }
            await SupportorPlugin.start(selectionText);
            ContextMenuController.removeAny();
          },
        ),
      );
    }
    return AdaptiveTextSelectionToolbar.buttonItems(
      anchors: editableTextState.contextMenuAnchors,
      buttonItems: buttonItems,
    );
  }

  Widget _buildCommentTextArea(BuildContext context, Illusts data) {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(left: 16.0, right: 16.0),
        child: InkWell(
          onTap: () {
            Leader.push(context, CommentPage(id: data.id));
          },
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.comment,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    SizedBox(
                      width: 4,
                    ),
                    Text(
                      I18n.of(context).view_comment,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ]),
            ),
          ),
        ),
      ),
    );
  }

  Future _longPressTag(BuildContext context, Tags f) async {
    switch (await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: RichText(
              text: TextSpan(children: [
                TextSpan(
                    text: "${f.name}",
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Theme.of(context).colorScheme.primary)),
                if (f.translatedName != null)
                  TextSpan(
                      text: "\n${"${f.translatedName}"}",
                      style: Theme.of(context).textTheme.bodyLarge!)
              ]),
            ),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 0);
                },
                child: Text(I18n.of(context).ban),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 1);
                },
                child: Text(I18n.of(context).bookmark),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 2);
                },
                child: Text(I18n.of(context).copy),
              ),
            ],
          );
        })) {
      case 0:
        {
          muteStore.insertBanTag(BanTagPersist(
              name: f.name, translateName: f.translatedName ?? ""));
        }
        break;
      case 1:
        {
          bookTagStore.bookTag(f.name);
        }
        break;
      case 2:
        {
          await Clipboard.setData(ClipboardData(text: f.name));
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            duration: Duration(seconds: 1),
            content: Text(I18n.of(context).copied_to_clipboard),
          ));
        }
    }
  }

  Widget buildRow(BuildContext context, Tags f) {
    return GestureDetector(
      onLongPress: () async {
        await _longPressTag(context, f);
      },
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return ResultPage(
            word: f.name,
            translatedName: f.translatedName ?? "",
          );
        }));
      },
      child: Container(
        height: 25,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondaryContainer,
          borderRadius: const BorderRadius.all(Radius.circular(12.5)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RichText(
                textAlign: TextAlign.start,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                text: TextSpan(
                    text: "#${f.name}",
                    children: [
                      TextSpan(
                        text: " ",
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall!
                            .copyWith(fontSize: 12),
                      ),
                      if (f.translatedName != null)
                        TextSpan(
                            text: "${f.translatedName}",
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .copyWith(fontSize: 12))
                    ],
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 12))),
          ],
        ),
      ),
    );
  }

  Future<void> _push2UserPage(BuildContext context, Illusts illust) async {
    await Leader.push(
        context,
        UsersPage(
          id: illust.user.id,
          userStore: userStore,
          heroTag: this.hashCode.toString(),
        ));
    widget.illustStore?.illusts!.user.isFollowed = userStore!.isFollow;
  }

  Widget _buildNameAvatar(BuildContext context, Illusts illust) {
    if (userStore == null)
      userStore = UserStore(illust.user.id, null, illust.user);
    return Observer(builder: (_) {
      return InkWell(
        onTap: () async {
          await _push2UserPage(context, illust);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
                child: Hero(
                  tag: illust.user.profileImageUrls.medium +
                      this.hashCode.toString(),
                  child: PainterAvatar(
                    url: illust.user.profileImageUrls.medium,
                    id: illust.user.id,
                    size: Size(32, 32),
                    onTap: () async {
                      await Leader.push(
                          context,
                          UsersPage(
                            id: illust.user.id,
                            userStore: userStore,
                            heroTag: this.hashCode.toString(),
                          ));
                      widget.illustStore?.illusts!.user.isFollowed =
                          userStore!.isFollow;
                    },
                  ),
                ),
                padding: EdgeInsets.only(left: 16.0)),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Hero(
                      tag: illust.user.name + this.hashCode.toString(),
                      child: SelectionArea(
                        child: GestureDetector(
                          onTap: () {
                            _push2UserPage(context, illust);
                          },
                          child: Text(
                            illust.user.name,
                            style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .color),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            UserFollowButton(
              followed: userStore?.isFollow ?? illust.user.isFollowed ?? false,
              onPressed: () async {
                await userStore?.follow();
                if (userStore?.isFollow != null) {
                  widget.illustStore?.illusts?.user.isFollowed =
                      userStore?.isFollow;
                }
              },
            ),
            SizedBox(
              width: 12,
            )
          ],
        ),
      );
    });
  }

  Future<void> supportTranslateCheck() async {
    if (!Platform.isAndroid) return;
    bool results = await SupportorPlugin.processText();
    if (mounted) {
      setState(() {
        supportTranslate = results;
      });
    }
  }
}
