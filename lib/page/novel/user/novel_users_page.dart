import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pixez/component/null_hero.dart';
import 'package:pixez/component/painter_avatar.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/document_plugin.dart';
import 'package:pixez/er/hoster.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/illust.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/follow/follow_list.dart';
import 'package:pixez/page/novel/component/novel_lighting_store.dart';
import 'package:pixez/page/novel/user/novel_user_bookmark_page.dart';
import 'package:pixez/page/novel/user/novel_user_work_page.dart';
import 'package:pixez/page/report/report_items_page.dart';
import 'package:pixez/page/user/detail/user_detail.dart';
import 'package:pixez/page/user/user_store.dart';
import 'package:pixez/page/user/users_page.dart';
import 'package:share_plus/share_plus.dart';

class NovelUsersPage extends StatefulWidget {
  final int id;
  final UserStore? userStore;
  final String? heroTag;

  const NovelUsersPage(
      {Key? key, required this.id, this.userStore, this.heroTag})
      : super(key: key);

  @override
  State<NovelUsersPage> createState() => _NovelUsersPageState();
}

class _NovelUsersPageState extends State<NovelUsersPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _tabIndex = 0;
  late UserStore userStore;
  late ScrollController _scrollController;
  late NovelLightingStore _bookMarkStore;
  late NovelLightingStore _workStore;

  @override
  void initState() {
    _workStore = NovelLightingStore(
        () => apiClient.getUserNovels(widget.id),
        EasyRefreshController(
            controlFinishLoad: true, controlFinishRefresh: true));
    _bookMarkStore = NovelLightingStore(
        () => apiClient.getUserBookmarkNovel(widget.id, "public"),
        EasyRefreshController(
            controlFinishLoad: true, controlFinishRefresh: true));
    userStore = widget.userStore ?? UserStore(widget.id, null, null);
    userStore.firstFetch();
    _tabController = TabController(length: 3, vsync: this);
    _scrollController = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Observer(builder: (_) {
        return NestedScrollView(
          headerSliverBuilder:
              (BuildContext context, bool? innerBoxIsScrolled) {
            return _HeaderSlivers(innerBoxIsScrolled, context);
          },
          body: TabBarView(controller: _tabController, children: [
            NovelUserWorkPage(
              id: widget.id,
              store: _workStore,
            ),
            NovelUserBookmarkPage(
              id: widget.id,
              store: _bookMarkStore,
            ),
            UserDetailPage(
              key: PageStorageKey('NovelTab2'),
              userDetail: userStore.userDetail,
              isNewNested: true,
              isNovel: true,
            ),
          ]),
        );
      }),
    );
  }

  List<Widget> _HeaderSlivers(bool? innerBoxIsScrolled, BuildContext context) {
    return [
      SliverOverlapAbsorber(
        handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
        sliver: SliverAppBar(
          pinned: true,
          elevation: 0.0,
          forceElevated: innerBoxIsScrolled ?? false,
          expandedHeight: 280,
          actions: <Widget>[
            Builder(builder: (context) {
              return IconButton(
                  icon: Icon(Icons.share),
                  onPressed: () {
                    final box = context.findRenderObject() as RenderBox?;
                    final pos = box != null
                        ? box.localToGlobal(Offset.zero) & box.size
                        : null;
                    Share.share('https://www.pixiv.net/users/${widget.id}',
                        sharePositionOrigin: pos);
                  });
            }),
            _buildPopMenu(context)
          ],
          flexibleSpace: FlexibleSpaceBar(
            collapseMode: CollapseMode.pin,
            background: Container(
              color: Theme.of(context).cardColor,
              child: Stack(
                children: <Widget>[
                  _buildBackground(context),
                  _buildFakeBg(context),
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
                              _buildComment(context),
                              Tab(
                                text: " ",
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          bottom: ColoredTabBar(
            Theme.of(context).cardColor,
            TabBar(
              controller: _tabController,
              onTap: (index) {
                setState(() {
                  _tabIndex = index;
                });
              },
              indicatorSize: TabBarIndicatorSize.label,
              tabs: [
                GestureDetector(
                  onDoubleTap: () {
                    if (_tabIndex == 0) _scrollController.position.jumpTo(0);
                  },
                  child: Tab(
                    text: I18n.of(context).works,
                  ),
                ),
                GestureDetector(
                  onDoubleTap: () {
                    if (_tabIndex == 1) _scrollController.position.jumpTo(0);
                  },
                  child: Tab(
                    text: I18n.of(context).bookmark,
                  ),
                ),
                GestureDetector(
                  onDoubleTap: () {
                    if (_tabIndex == 2) _scrollController.position.jumpTo(0);
                  },
                  child: Tab(
                    text: I18n.of(context).detail,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ];
  }

  Widget _buildBackground(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).padding.top + 160,
        child: userStore.userDetail != null
            ? userStore.userDetail!.profile.background_image_url != null
                ? InkWell(
                    onLongPress: () {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text(I18n.of(context).save),
                              actions: [
                                TextButton(
                                    onPressed: () async {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text(I18n.of(context).cancel)),
                                TextButton(
                                    onPressed: () async {
                                      Navigator.of(context).pop();
                                      await _saveUserBg(userStore.userDetail!
                                          .profile.background_image_url!);
                                    },
                                    child: Text(I18n.of(context).ok)),
                              ],
                            );
                          });
                    },
                    child: CachedNetworkImage(
                      imageUrl:
                          userStore.userDetail!.profile.background_image_url!,
                      fit: BoxFit.fitWidth,
                      cacheManager: pixivCacheManager,
                      httpHeaders: Hoster.header(
                          url: userStore
                              .userDetail!.profile.background_image_url),
                    ),
                  )
                : Container(
                    color: Theme.of(context).colorScheme.secondary,
                  )
            : Container());
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
              totalComments: 0,
              series: null,
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

  PopupMenuButton<int> _buildPopMenu(BuildContext context) {
    return PopupMenuButton<int>(
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
                      title: Text('${I18n.of(context).block_user}?'),
                      actions: <Widget>[
                        TextButton(
                          child: Text("OK"),
                          onPressed: () {
                            Navigator.of(context).pop("OK");
                          },
                        ),
                        TextButton(
                          child: Text("CANCEL"),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        )
                      ],
                    );
                  });
              if (result == "OK") {
                await muteStore.insertBanUserId(
                    widget.id.toString(), userStore.userDetail!.user.name);
                Navigator.of(context).pop();
              }
            }
            break;
          case 2:
            {
              Clipboard.setData(ClipboardData(
                  text:
                      'painter:${userStore.userDetail?.user.name ?? ''}\npid:${widget.id}'));
              BotToast.showText(text: I18n.of(context).copied_to_clipboard);
              break;
            }
          case 3:
            {
              Reporter.show(
                  context,
                  () async => await muteStore.insertBanUserId(
                      widget.id.toString(), userStore.userDetail!.user.name));
              break;
            }
          case 4:
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (BuildContext context) {
              return UsersPage(
                id: widget.id,
              );
            }));
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
          PopupMenuItem<int>(
            value: 3,
            child: Text(I18n.of(context).report),
          ),
          PopupMenuItem<int>(
            value: 4,
            child: Text(I18n.of(context).illust_page),
          ),
        ];
      },
    );
  }

  Widget _buildFakeNameFollow(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                userStore.user?.name ?? "",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(
                userStore.userDetail == null
                    ? ""
                    : '${userStore.userDetail!.profile.total_follow_users} ${I18n.of(context).follow}',
                style: Theme.of(context).textTheme.bodySmall,
              )
            ]),
      ),
    );
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
              NullHero(
                tag: userStore.user?.name ?? "" + widget.heroTag.toString(),
                child: SelectionArea(
                  child: Text(
                    userStore.user?.name ?? "",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (BuildContext context) {
                    return Scaffold(
                      appBar: AppBar(
                        title: Text(I18n.of(context).followed),
                      ),
                      body: FollowList(
                        id: widget.id,
                        isNovel: true,
                      ),
                    );
                  }));
                },
                child: Text(
                  userStore.userDetail == null
                      ? ""
                      : '${userStore.userDetail!.profile.total_follow_users} ${I18n.of(context).follow}',
                  style: Theme.of(context).textTheme.bodySmall,
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
              userStore.userDetail == null
                  ? ""
                  : '${userStore.userDetail!.user.comment}',
              style: Theme.of(context).textTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
          child: _buildAvatarFollow(context),
          alignment: Alignment.bottomCenter,
        )
      ],
    );
  }

  _showSaveAvatarDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(I18n.of(context).save_painter_avatar),
            actions: [
              TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                  },
                  child: Text(I18n.of(context).cancel)),
              TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await _saveUserC();
                  },
                  child: Text(I18n.of(context).ok)),
            ],
          );
        });
  }

  Widget _buildAvatarFollow(BuildContext context) {
    return Container(
      child: Observer(
        builder: (_) => Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
              child: userStore.user != null
                  ? NullHero(
                      tag: userStore.user!.profileImageUrls.medium +
                          widget.heroTag.toString(),
                      child: PainterAvatar(
                        url: userStore.user!.profileImageUrls.medium,
                        size: Size(80, 80),
                        onTap: () {
                          _showSaveAvatarDialog();
                        },
                        id: userStore.user!.id,
                      ),
                    )
                  : Container(
                      width: 80,
                      height: 80,
                    ),
            ),
            Container(
              child: userStore.userDetail == null
                  ? Container(
                      padding: const EdgeInsets.only(right: 16.0, bottom: 4.0),
                      child: CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.only(right: 16.0, bottom: 4.0),
                      child: userStore.isFollow
                          ? MaterialButton(
                              textColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20.0, vertical: 0),
                              color: Theme.of(context).colorScheme.secondary,
                              onPressed: () {
                                if (accountStore.now != null) {
                                  if (int.parse(accountStore.now!.userId) !=
                                      widget.id) {
                                    userStore.follow(needPrivate: false);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'Who is the most beautiful person in the world?')));
                                  }
                                }
                              },
                              child: Text(I18n.of(context).followed),
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20))),
                            )
                          : OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                  ),
                                  side: BorderSide(),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 20.0, vertical: 0)),
                              onPressed: () {
                                if (accountStore.now != null) {
                                  if (int.parse(accountStore.now!.userId) !=
                                      widget.id) {
                                    userStore.follow(needPrivate: false);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'Who is the most beautiful person in the world?')));
                                  }
                                }
                              },
                              child: Text(
                                I18n.of(context).follow,
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .color),
                              ),
                            ),
                    ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildFakeBg(BuildContext context) {
    return Align(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            height: 55,
            color: Theme.of(context).cardColor,
          ),
          Container(
            color: Theme.of(context).cardColor,
            child: Column(
              children: <Widget>[
                _buildFakeNameFollow(context),
                Container(
                  height: 60,
                ),
                Tab(
                  text: " ",
                )
              ],
            ),
          ),
        ],
      ),
      alignment: Alignment.bottomCenter,
    );
  }
}
