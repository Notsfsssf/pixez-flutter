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
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pixez/component/null_hero.dart';
import 'package:pixez/document_plugin.dart';
import 'package:pixez/er/hoster.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/fluent/component/context_menu.dart';
import 'package:pixez/fluent/component/painter_avatar.dart';
import 'package:pixez/fluent/component/pixiv_image.dart';
import 'package:pixez/fluent/page/follow/follow_list.dart';
import 'package:pixez/fluent/page/report/report_items_page.dart';
import 'package:pixez/fluent/page/shield/shield_page.dart';
import 'package:pixez/fluent/page/user/bookmark/bookmark_page.dart';
import 'package:pixez/fluent/page/user/detail/user_detail.dart';
import 'package:pixez/fluent/page/user/works/works_page.dart';
import 'package:pixez/fluent/page/zoom/zoom_page.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/illust.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/user/user_store.dart';
import 'package:share_plus/share_plus.dart';

class UsersPage extends StatefulWidget {
  final int id;
  final UserStore? userStore;
  final String? heroTag;

  const UsersPage({Key? key, required this.id, this.userStore, this.heroTag})
      : super(key: key);

  @override
  _UsersPageState createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late UserStore userStore;
  late ScrollController _scrollController;
  bool backToTopVisible = false;
  BookmarkPageMethodRelay _bookmarkPageMethodRelay = BookmarkPageMethodRelay();

  @override
  void initState() {
    userStore = widget.userStore ?? UserStore(widget.id, null, null);
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.hasClients) {
        if (_scrollController.offset > 100) {
          if (!backToTopVisible) {
            setState(() {
              backToTopVisible = true;
            });
          }
        } else {
          if (backToTopVisible) {
            setState(() {
              backToTopVisible = false;
            });
          }
        }
      }
    });
    super.initState();
    userStore.firstFetch();
    muteStore.fetchBanUserIds();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Observer(builder: (_) {
      if (muteStore.banUserIds.isNotEmpty) {
        if (muteStore.banUserIds
            .map((element) => int.parse(element.userId!))
            .contains(widget.id)) {
          return ScaffoldPage(
            content: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('X_X'),
                  Text('${widget.id}'),
                  FilledButton(
                    child: Text(I18n.of(context).shielding_settings),
                    onPressed: () {
                      Leader.push(
                        context,
                        ShieldPage(),
                        icon: Icon(FluentIcons.settings),
                        title: Text(I18n.of(context).shielding_settings),
                      );
                    },
                  )
                ],
              ),
            ),
          );
        }
      }

      if (userStore.errorMessage != null) {
        if (userStore.errorMessage!.contains("404"))
          return ScaffoldPage(
            content: Container(
                child: Center(
              child: Text('404 not found'),
            )),
          );
        return ScaffoldPage(
          content: Container(
              child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Http error\n${userStore.errorMessage}',
                    maxLines: 5,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FilledButton(
                    onPressed: () {
                      userStore.errorMessage = null;
                      userStore.firstFetch();
                    },
                    child: Text(I18n.of(context).refresh),
                  ),
                )
              ],
            ),
          )),
        );
      }
      if (userStore.user == null) {
        return ScaffoldPage(
          content: Container(
              child: Center(
            child: ProgressRing(),
          )),
        );
      }
      return NavigationView(
        pane: NavigationPane(
          displayMode: PaneDisplayMode.top,
          selected: _tabIndex,
          onChanged: (value) {
            if (value > 2) return;
            _tabIndex = value;
            setState(() {});
          },
          items: [
            PaneItem(
                icon: Icon(FluentIcons.info),
                title: Text(I18n.of(context).detail),
                body: _buildDetail(context)),
            PaneItem(
              icon: Icon(FluentIcons.picture_library),
              title: Text(I18n.of(context).works),
              body: WorksPage(
                id: widget.id,
              ),
            ),
            PaneItem(
              icon: Icon(FluentIcons.bookmarks),
              title: Text(I18n.of(context).bookmark),
              body: BookmarkPage(
                isNested: true,
                id: widget.id,
                relay: _bookmarkPageMethodRelay,
              ),
            ),
          ],
          footerItems: [
            PaneItemAction(
              icon: Icon(FluentIcons.share),
              onTap: () =>
                  Share.share('https://www.pixiv.net/users/${widget.id}'),
            ),
            PaneItemExpander(
              icon: Container(),
              body: Container(),
              items: [
                PaneItemAction(
                  icon: Container(),
                  title: Text(I18n.of(context).quietly_follow),
                  onTap: () {
                    userStore.follow(needPrivate: true);
                  },
                ),
                PaneItemAction(
                  icon: Container(),
                  title: Text(I18n.of(context).block_user),
                  onTap: () async {
                    await showDialog(
                      context: context,
                      builder: (context) => ContentDialog(
                        title: Text('${I18n.of(context).block_user}?'),
                        actions: <Widget>[
                          FilledButton(
                            child: Text(I18n.of(context).ok),
                            onPressed: () async {
                              await muteStore.insertBanUserId(
                                  widget.id.toString(),
                                  userStore.userDetail!.user.name);
                              Navigator.of(context).pop();
                            },
                          ),
                          Button(
                            child: Text(I18n.of(context).cancel),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          )
                        ],
                      ),
                    );
                  },
                ),
                PaneItemAction(
                  icon: Container(),
                  title: Text(I18n.of(context).copymessage),
                  onTap: () {
                    Clipboard.setData(ClipboardData(
                        text:
                            'painter:${userStore.userDetail?.user.name ?? ''}\npid:${widget.id}'));
                    BotToast.showText(
                        text: I18n.of(context).copied_to_clipboard);
                  },
                ),
                PaneItemAction(
                  icon: Container(),
                  title: Text(I18n.of(context).report),
                  onTap: () {
                    Reporter.show(
                        context,
                        () async => await muteStore.insertBanUserId(
                            widget.id.toString(),
                            userStore.userDetail!.user.name));
                  },
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildNameFollow(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => Container(
        color: FluentTheme.of(context).cardColor,
        width: constraints.maxWidth,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              NullHero(
                tag: userStore.user?.name ?? "" + widget.heroTag.toString(),
                child: Text(
                  userStore.user?.name ?? "",
                  style: FluentTheme.of(context).typography.subtitle,
                ),
              ),
              IconButton(
                onPressed: () {
                  Leader.push(
                    context,
                    ScaffoldPage(
                      header: PageHeader(
                        title: Text(I18n.of(context).followed),
                      ),
                      content: FollowList(id: widget.id),
                    ),
                    icon: Icon(FluentIcons.follow_user),
                    title: Text(I18n.of(context).followed),
                  );
                },
                icon: Text(
                  userStore.userDetail == null
                      ? ""
                      : '${userStore.userDetail!.profile.total_follow_users} ${I18n.of(context).follow}',
                  style: FluentTheme.of(context).typography.caption,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final follow = () {
      if (accountStore.now == null) return;

      if (int.parse(accountStore.now!.userId) != widget.id) {
        userStore.follow(needPrivate: false);
      } else {
        displayInfoBar(context,
            builder: (context, VoidCallback) => InfoBar(
                  title: Text('Who is the most beautiful person in the world?'),
                ));
      }
    };

    Widget w = Container(
      child: Observer(
        builder: (_) => Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
              child: NullHero(
                tag: userStore.user!.profileImageUrls.medium +
                    widget.heroTag.toString(),
                child: PainterAvatar(
                  url: userStore.user!.profileImageUrls.medium,
                  size: Size(80, 80),
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return ContentDialog(
                            title: Text(I18n.of(context).save_painter_avatar),
                            actions: [
                              Button(
                                  onPressed: () async {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(I18n.of(context).cancel)),
                              FilledButton(
                                  onPressed: () async {
                                    Navigator.of(context).pop();
                                    await _saveUserC();
                                  },
                                  child: Text(I18n.of(context).ok)),
                            ],
                          );
                        });
                  },
                  id: userStore.user!.id,
                ),
              ),
            ),
            Container(
              child: userStore.userDetail == null
                  ? Container(
                      padding: const EdgeInsets.only(right: 16.0, bottom: 4.0),
                      child: ProgressRing(),
                    )
                  : Padding(
                      padding: const EdgeInsets.only(right: 16.0, bottom: 4.0),
                      child: userStore.isFollow
                          ? FilledButton(
                              onPressed: follow,
                              child: Text(I18n.of(context).followed),
                            )
                          : OutlinedButton(
                              onPressed: follow,
                              child: Text(I18n.of(context).follow),
                            ),
                    ),
            )
          ],
        ),
      ),
    );
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(top: 25),
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            height: 60.0,
            child: Container(
              color: FluentTheme.of(context)
                  .acrylicBackgroundColor
                  .withValues(alpha: 255 * .5),
            ),
          ),
        ),
        Align(
          child: w,
          alignment: Alignment.bottomCenter,
        )
      ],
    );
  }

  _saveUserBg(String url) async {
    try {
      final result = await pixivCacheManager!.downloadFile(url, authHeaders: {
        'referer': 'https://app-api.pixiv.net/',
      });
      final bytes = await result.file.readAsBytes();
      await DocumentPlugin.save(bytes, "${widget.id}_bg.jpg");
      BotToast.showText(text: I18n.of(context).saved);
    } catch (e) {
      print(e);
    }
  }

  Future _saveUserC() async {
    var url = userStore.userDetail!.user.profileImageUrls.medium;
    String meme = url.split(".").last;
    if (meme.isEmpty) meme = "jpg";
    var replaceAll = userStore.userDetail!.user.name
        .replaceAll("/", "")
        .replaceAll("\\", "")
        .replaceAll(":", "")
        .replaceAll("*", "")
        .replaceAll("?", "")
        .replaceAll(">", "")
        .replaceAll("|", "")
        .replaceAll("<", "");
    String fileName = "${replaceAll}_${userStore.userDetail!.user.id}.${meme}";
    try {
      String tempFile = (await getTemporaryDirectory()).path + "/$fileName";
      final dio = Dio(BaseOptions(headers: Hoster.header(url: url)));
      if (!userSetting.disableBypassSni) {
        dio.httpClientAdapter = await ApiClient.createCompatibleClient();
      }
      await dio.download(url, tempFile, deleteOnError: true);
      File file = File(tempFile);
      if (file.existsSync()) {
        await saveStore.saveToGallery(
            file.readAsBytesSync(),
            Illusts(
              user: User(
                id: userStore.userDetail!.user.id,
                name: replaceAll,
                profileImageUrls: userStore.userDetail!.user.profileImageUrls,
                isFollowed: userStore.userDetail!.user.isFollowed,
                account: userStore.userDetail!.user.account,
                comment: userStore.userDetail!.user.comment,
              ),
              metaPages: [],
              type: '',
              width: 0,
              series: null,
              totalComments: 0,
              totalBookmarks: 0,
              visible: false,
              isMuted: false,
              sanityLevel: 0,
              tags: [],
              caption: '',
              pageCount: 0,
              metaSinglePage: MetaSinglePage(originalImageUrl: ''),
              tools: [],
              height: 0,
              restrict: 0,
              createDate: '',
              id: 0,
              xRestrict: 0,
              imageUrls: ImageUrls(squareMedium: '', medium: '', large: ''),
              title: '',
              isBookmarked: false,
              totalView: 0,
              illustAIType: 1,
            ),
            fileName);
        BotToast.showText(text: I18n.of(context).complete);
      } else
        BotToast.showText(text: I18n.of(context).failed);
    } catch (e) {
      print(e);
    }
  }

  _buildBackground(BuildContext context) {
    return ContextMenu(
      child: CachedNetworkImage(
        imageUrl: userStore.userDetail!.profile.background_image_url!,
        fit: BoxFit.fitWidth,
        cacheManager: pixivCacheManager,
        httpHeaders: Hoster.header(
          url: userStore.userDetail!.profile.background_image_url,
        ),
      ),
      items: [
        MenuFlyoutItem(
          text: Text(I18n.of(context).show),
          onPressed: () async {
            await Leader.push(
                context,
                ZoomPage(
                    url: userStore.userDetail!.profile.background_image_url!),
                icon: Icon(FluentIcons.picture),
                title: Text(I18n.of(context).painter +
                    (userStore.userDetail?.user.id.toString() ?? '')));
          },
        ),
        MenuFlyoutItem(
          text: Text(I18n.of(context).save),
          onPressed: () async {
            await _saveUserBg(
                userStore.userDetail!.profile.background_image_url!);
          },
        ),
      ],
    );
  }

  _buildDetail(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          const height = 300.0;
          final nobg =
              userStore.userDetail?.profile.background_image_url == null;

          final background = nobg
              ? Container(color: FluentTheme.of(context).accentColor)
              : _buildBackground(context);

          return ListView(
            children: [
              Container(
                height: height * (nobg ? .55 : 1),
                color: FluentTheme.of(context).cardColor,
                child: Stack(
                  children: <Widget>[
                    Container(
                      width: width,
                      height: height * (nobg ? .3 : .75),
                      child: background,
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          _buildHeader(context),
                          Container(
                            height: height * .25,
                            color: FluentTheme.of(context).cardColor,
                            child: _buildNameFollow(context),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              userStore.userDetail != null
                  ? UserDetailPage(userDetail: userStore.userDetail!)
                  : Container()
            ],
          );
        },
      );

  @override
  bool get wantKeepAlive => true;
}
