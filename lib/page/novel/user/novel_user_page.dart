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
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/component/painter_avatar.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/page/follow/follow_list.dart';
import 'package:pixez/page/novel/user/novel_user_bookmark_page.dart';
import 'package:pixez/page/novel/user/novel_user_work_page.dart';
import 'package:pixez/page/user/detail/user_detail.dart';
import 'package:pixez/page/user/user_store.dart';
import 'package:share_plus/share_plus.dart';

class NovelUserPage extends StatefulWidget {
  final int id;

  const NovelUserPage({Key? key, required this.id}) : super(key: key);

  @override
  _NovelUserPageState createState() => _NovelUserPageState();
}

class _NovelUserPageState extends State<NovelUserPage>
    with SingleTickerProviderStateMixin {
  late UserStore userStore;
  late ScrollController _scrollController;
  late TabController _tabController;

  @override
  void initState() {
    _scrollController = ScrollController();
    userStore = UserStore(widget.id)..firstFetch();
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      if (userStore.errorMessage != null) {
        if (userStore.errorMessage == '404')
          return Scaffold(
            appBar: AppBar(),
            body: Container(
                child: Center(
              child: Text('404 not found'),
            )),
          );
        return Scaffold(
          appBar: AppBar(),
          body: Container(
              child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Http error'),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: MaterialButton(
                    color: Theme.of(context).colorScheme.secondary,
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

      if (userStore.userDetail != null)
        return SelectionArea(
          child: Scaffold(
            body: ExtendedNestedScrollView(
                onlyOneScrollInBody: true,
                headerSliverBuilder:
                    (BuildContext context, bool? innerBoxIsScrolled) {
                  return <Widget>[
                    SliverAppBar(
                      pinned: true,
                      elevation: 0.0,
                      forceElevated: innerBoxIsScrolled ?? false,
                      expandedHeight: 280,
                      actions: <Widget>[
                        IconButton(
                            icon: Icon(Icons.share),
                            onPressed: () {
                              Share.share(
                                  'https://www.pixiv.net/users/${widget.id}');
                            }),
                        PopupMenuButton<int>(
                          onSelected: (index) async {
                            switch (index) {
                              case 0:
                                userStore.follow(needPrivate: true);
                                break;
                              case 1:
                                {
                                  final result = await showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: Text(
                                              '${I18n.of(context).block_user}?'),
                                          actions: <Widget>[
                                            TextButton(
                                              child: Text("CANCEL"),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                            TextButton(
                                              child: Text("OK"),
                                              onPressed: () {
                                                Navigator.of(context).pop("OK");
                                              },
                                            ),
                                          ],
                                        );
                                      });
                                  if (result == "OK") {
                                    await muteStore.insertBanUserId(
                                        widget.id.toString(),
                                        userStore.userDetail!.user.name);
                                    Navigator.of(context).pop();
                                  }
                                }
                                break;
                              case 2:
                                {
                                  Clipboard.setData(ClipboardData(
                                      text:
                                          'painter:${userStore.userDetail?.user.name ?? ''}\npid:${widget.id}'));
                                  BotToast.showText(
                                      text:
                                          I18n.of(context).copied_to_clipboard);
                                  break;
                                }
                              default:
                            }
                          },
                          itemBuilder: (context) {
                            return [
                              PopupMenuItem<int>(
                                value: 0,
                                child: Text(I18n.of(context).quietly_follow),
                              ),
                              PopupMenuItem<int>(
                                value: 1,
                                child: Text(I18n.of(context).block_user),
                              ),
                              PopupMenuItem<int>(
                                value: 2,
                                child: Text(I18n.of(context).copymessage),
                              ),
                            ];
                          },
                        )
                      ],
                      flexibleSpace: FlexibleSpaceBar(
                        collapseMode: CollapseMode.pin,
                        background: Container(
                          color: Theme.of(context).cardColor,
                          child: Stack(
                            children: <Widget>[
                              Container(
                                  width: MediaQuery.of(context).size.width,
                                  height:
                                      MediaQuery.of(context).padding.top + 160,
                                  child: userStore.userDetail!.profile
                                              .background_image_url !=
                                          null
                                      ? PixivImage(userStore.userDetail!.profile
                                          .background_image_url!)
                                      : Container(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                        )),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    _buildHeader(context),
                                    Container(
                                      color: Theme.of(context).cardColor,
                                      child: Column(
                                        children: <Widget>[
                                          _buildNameFollow(context),
                                          _buildComment(context)
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SliverPersistentHeader(
                      delegate: StickyTabBarDelegate(
                          child: TabBar(
                        controller: _tabController,
                        onTap: (index) {
                          setState(() {
                            _tabIndex = index;
                          });
                        },
                        labelColor:
                            Theme.of(context).textTheme.bodyText1!.color,
                        tabs: [
                          Tab(
                            text: I18n.of(context).works,
                          ),
                          Tab(
                            text: I18n.of(context).bookmark,
                          ),
                          Tab(
                            text: I18n.of(context).detail,
                          ),
                        ],
                      )),
                      pinned: true,
                    ),
                  ];
                },
                controller: _scrollController,
                pinnedHeaderSliverHeightBuilder: () {
                  return MediaQuery.of(context).padding.top +
                      kToolbarHeight +
                      46.0;
                },
                body: IndexedStack(
                  index: _tabIndex,
                  children: [
                    ExtendedVisibilityDetector(
                      uniqueKey: Key('Tab0'),
                      child: NovelUserWorkPage(
                        id: widget.id,
                        isNested: true,
                      ),
                    ),
                    ExtendedVisibilityDetector(
                      uniqueKey: Key('Tab1'),
                      child: NovelUserBookmarkPage(
                        id: widget.id,
                        isNested: true,
                      ),
                    ),
                    ExtendedVisibilityDetector(
                        uniqueKey: Key('Tab2'),
                        child:
                            UserDetailPage(userDetail: userStore.userDetail!)),
                  ],
                )),
          ),
        );
      else
        return Scaffold(
          appBar: AppBar(),
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
    });
  }

  Widget _buildNameFollow(BuildContext context) {
    return Container(
      color: Theme.of(context).cardColor,
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                userStore.userDetail!.user.name,
                style: Theme.of(context).textTheme.headline6,
              ),
              InkWell(
                onTap: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (BuildContext context) {
                    return Scaffold(
                      appBar: AppBar(
                        title: Text(I18n.of(context).followed),
                      ),
                      body: FollowList(id: widget.id),
                    );
                  }));
                },
                child: Text(
                  '${userStore.userDetail!.profile.total_follow_users} ${I18n.of(context).follow}',
                  style: Theme.of(context).textTheme.caption,
                ),
              )
            ]),
      ),
    );
  }

  Widget _buildComment(BuildContext context) {
    return Container(
      color: Theme.of(context).cardColor,
      width: MediaQuery.of(context).size.width,
      height: 60,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
        child: SelectionContainer.disabled(
          child: SingleChildScrollView(
            child: Text(
              '${userStore.userDetail!.user.comment}',
              style: Theme.of(context).textTheme.caption,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
              child: PainterAvatar(
                url: userStore.userDetail!.user.profileImageUrls.medium,
                size: Size(80, 80),
                onTap: () {},
                id: userStore.userDetail!.user.id,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16.0, bottom: 4.0),
              child: MaterialButton(
                textColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 0),
                color: userStore.isFollow
                    ? Theme.of(context).colorScheme.secondary
                    : Colors.grey,
                onPressed: () {
                  if (accountStore.now != null) {
                    if (int.parse(accountStore.now!.userId) != widget.id) {
                      userStore.follow(needPrivate: false);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              'Who is the most beautiful person in the world?')));
                    }
                  }
                },
                child: Text(userStore.isFollow
                    ? I18n.of(context).followed
                    : I18n.of(context).follow),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20))),
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
            height: 55.0,
            child: Container(
              color: Theme.of(context).cardColor,
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
}

class StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar child;

  StickyTabBarDelegate({required this.child});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      child: this.child,
      color: Theme.of(context).cardColor,
    );
  }

  @override
  double get maxExtent => this.child.preferredSize.height;

  @override
  double get minExtent => this.child.preferredSize.height;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
