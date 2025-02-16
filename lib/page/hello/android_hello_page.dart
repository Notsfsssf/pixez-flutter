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

import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:bot_toast/bot_toast.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pixez/component/painter_avatar.dart';
import 'package:pixez/constants.dart';
import 'package:pixez/deep_link_plugin.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/er/prefer.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/page/Init/guide_page.dart';
import 'package:pixez/page/hello/new/new_page.dart';
import 'package:pixez/page/hello/ranking/rank_page.dart';
import 'package:pixez/page/hello/recom/recom_spotlight_page.dart';
import 'package:pixez/page/hello/setting/setting_page.dart';
import 'package:pixez/page/login/login_page.dart';
import 'package:pixez/page/saucenao/saucenao_page.dart';
import 'package:pixez/page/search/search_page.dart';
import 'package:pixez/page/search/suggest/search_suggestion_page.dart';
import 'package:pixez/page/webview/saucenao_webview_page.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

class AndroidHelloPage extends StatefulWidget {
  const AndroidHelloPage({Key? key}) : super(key: key);

  @override
  _AndroidHelloPageState createState() => _AndroidHelloPageState();
}

class _AndroidHelloPageState extends State<AndroidHelloPage> {
  late List<Widget> _pageList;
  DateTime? _preTime;
  double? bottomNavigatorHeight = null;

  void toggleFullscreen() {
    fullScreenStore.toggle();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      if (accountStore.now != null && (Platform.isIOS || Platform.isAndroid)) {
        return _buildScaffold(context);
      }
      if (accountStore.now == null && accountStore.feching) {
        return Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      }
      return LoginPage();
    });
  }

  Widget _buildScaffold(BuildContext context) {
    if (bottomNavigatorHeight == null) {
      bottomNavigatorHeight = MediaQuery.of(context).padding.bottom + 80;
    }
    return LayoutBuilder(builder: (context, constraints) {
      final wide = constraints.maxWidth > constraints.maxHeight;
      return PopScope(
          onPopInvokedWithResult: (didPop, result) async {
            userSetting.setAnimContainer(!userSetting.animContainer);
            if (didPop) return;
            if (!userSetting.isReturnAgainToExit) {
              return;
            }
            if (_preTime == null ||
                DateTime.now().difference(_preTime!) > Duration(seconds: 2)) {
              setState(() {
                _preTime = DateTime.now();
              });
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                duration: Duration(seconds: 1),
                content: Text(I18n.of(context).return_again_to_exit),
              ));
            }
          },
          canPop: !userSetting.isReturnAgainToExit ||
              _preTime != null &&
                  DateTime.now().difference(_preTime!) <= Duration(seconds: 2),
          child: Scaffold(
            body: Row(children: [
              if (wide) ..._buildRail(context),
              Expanded(child: _buildPageView(context))
            ]),
            extendBody: true,
            bottomNavigationBar: wide
                ? null
                : Observer(builder: (context) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      transform: Matrix4.translationValues(
                          0,
                          fullScreenStore.fullscreen
                              ? bottomNavigatorHeight!
                              : 0,
                          0),
                      child: _buildNavigationBar(context),
                    );
                  }),
          ));
    });
  }

  Widget _buildPageView(BuildContext context) {
    return Stack(
      children: [
        _buildPageContent(context),
        Positioned(
          bottom: MediaQuery.of(context).padding.bottom + 16,
          right: 16,
          child: Observer(builder: (context) {
            return AnimatedToggleFullscreenFAB(
                isFullscreen: fullScreenStore.fullscreen,
                toggleFullscreen: toggleFullscreen);
          }),
        )
      ],
    );
  }

  Widget _buildNavigationBar(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: NavigationBar(
          height: 68,
          backgroundColor:
              Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
          destinations: [
            NavigationDestination(
                icon: Icon(Icons.home), label: I18n.of(context).home),
            NavigationDestination(
                icon: Icon(
                  Icons.leaderboard,
                ),
                label: I18n.of(context).rank),
            NavigationDestination(
                icon: Icon(Icons.favorite), label: I18n.of(context).quick_view),
            NavigationDestination(
                icon: Icon(Icons.search), label: I18n.of(context).search),
            NavigationDestination(
                icon: Icon(Icons.more_horiz), label: I18n.of(context).more)
          ],
          selectedIndex: index,
          onDestinationSelected: (index) {
            if (this.index == index) {
              topStore.setTop("${index + 1}00");
            }
            setState(() {
              this.index = index;
            });
            if (_pageController.hasClients) _pageController.jumpToPage(index);
          },
        ),
      ),
    );
  }

  Widget _buildPageContent(BuildContext context) {
    return PageView.builder(
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return _pageList[index];
      },
      onPageChanged: (index) {
        setState(() {
          this.index = index;
        });
      },
      controller: _pageController,
      itemCount: _pageList.length,
    );
  }

  List<Widget> _buildRail(BuildContext context) {
    return [
      Stack(
        children: [
          NavigationRail(
            selectedIndex: index,
            labelType: NavigationRailLabelType.all,
            onDestinationSelected: (int index) {
              _pageController.jumpToPage(index);
              setState(() {
                index = index;
              });
            },
            destinations: <NavigationRailDestination>[
              NavigationRailDestination(
                  icon: Icon(Icons.home), label: Text(I18n.of(context).home)),
              NavigationRailDestination(
                  icon: Icon(Icons.leaderboard),
                  label: Text(I18n.of(context).rank)),
              NavigationRailDestination(
                  icon: Icon(Icons.favorite),
                  label: Text(I18n.of(context).quick_view)),
              NavigationRailDestination(
                  icon: Icon(Icons.search),
                  label: Text(I18n.of(context).search)),
              NavigationRailDestination(
                  icon: Icon(Icons.more_horiz),
                  label: Text(I18n.of(context).more)),
            ],
          ),
          Positioned(
            left: 0.0,
            right: 0.0,
            bottom: 0.0,
            child: Container(
              padding: EdgeInsets.only(
                  left: MediaQuery.of(context).padding.left,
                  bottom: MediaQuery.of(context).padding.bottom + 4.0),
              child: Container(
                alignment: Alignment.center,
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: accountStore.now != null
                        ? PainterAvatar(
                            url: accountStore.now!.userImage,
                            id: int.tryParse(accountStore.now!.userId) ?? 0)
                        : Container(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      const VerticalDivider(thickness: 1, width: 1),
    ];
  }

  late int index;
  late PageController _pageController;
  late StreamSubscription _intentDataStreamSubscription;
  bool hasNewVersion = false;

  @override
  void initState() {
    fetcher.context = context;
    Constants.type = 0;
    _pageList = [
      RecomSpolightPage(),
      RankPage(),
      NewPage(),
      SearchPage(),
      SettingPage()
    ];
    index = userSetting.welcomePageNum;
    _pageController = PageController(initialPage: index);
    super.initState();
    saveStore.ctx = this.context;
    saveStore.saveStream.listen((stream) {
      saveStore.listenBehavior(stream);
    });
    initPlatformState();
    _intentDataStreamSubscription = ReceiveSharingIntent.instance
        .getMediaStream()
        .listen((List<SharedMediaFile> value) {
      for (var i in value) {
        if (i.type == SharedMediaType.text) {
          _showChromeLink(i.path);
          continue;
        }
        if (i.type == SharedMediaType.image) {
          if (userSetting.useSaunceNaoWebview) {
            Leader.push(context, SauncenaoWebview(path: i.path));
          } else {
            Leader.push(
                context,
                SauceNaoPage(
                  path: i.path,
                ));
          }
        }
      }
    }, onError: (err) {
      print("getIntentDataStream error: $err");
    });
    ReceiveSharingIntent.instance
        .getInitialMedia()
        .then((List<SharedMediaFile> value) {
      for (var i in value) {
        if (i.type == SharedMediaType.text) {
          _showChromeLink(i.path);
          continue;
        }
        if (i.type == SharedMediaType.image) {
          if (userSetting.useSaunceNaoWebview) {
            Leader.push(context, SauncenaoWebview(path: i.path));
          } else {
            Leader.push(
                context,
                SauceNaoPage(
                  path: i.path,
                ));
          }
        }
      }
    });
    initPlatform();
  }

  VoidCallback? _LinkCloser = null;

  _showChromeLink(String link) {
    final numId = int.tryParse(link);
    if (numId != null) {
      Leader.push(
          context,
          SearchSuggestionPage(
            preword: link,
          ));
      return;
    }
    Uri? uri = Uri.tryParse(link);
    if (uri == null) return;
    if (uri.scheme == "pixiv") {
      if (uri.host.contains("account")) return;
    }
    _LinkCloser = BotToast.showCustomText(
        onlyOne: true,
        duration: Duration(seconds: 4),
        toastBuilder: (textCancel) => Align(
              alignment: Alignment(0, 0.8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12))),
                  child: InkWell(
                    onTap: () {
                      if (_LinkCloser != null) _LinkCloser!();
                      var uri = Uri.tryParse(link);
                      if (uri != null) {
                        Leader.pushWithUri(context, uri);
                      }
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 8.0),
                            child: Text(link),
                          ),
                        ),
                        Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            child: IconButton(
                              icon: Icon(
                                Icons.copy,
                              ),
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: link));
                                if (_LinkCloser != null) {
                                  _LinkCloser!();
                                }
                              },
                            )),
                        Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            child: Icon(
                              Icons.link_rounded,
                            )),
                      ],
                    ),
                  ),
                ),
              ),
            ));
  }

  late StreamSubscription _sub;

  initPlatform() async {
    try {
      String? initLastLink = await DeepLinkPlugin.getLatestLink();
      Uri? initialLink =
          initLastLink != null ? Uri.tryParse(initLastLink) : null;
      if (initialLink != null) Leader.pushWithUri(context, initialLink);
      _sub = DeepLinkPlugin.uriLinkStream
          .listen((Uri? link) => Leader.pushWithUri(context, link!));
    } catch (e) {
      print(e);
    }
  }

  initPermission(BuildContext context) async {
    try {
      if (Platform.isAndroid && userSetting.saveMode != 1) {
        final info = await DeviceInfoPlugin().androidInfo;
        Permission permission = (info.version.sdkInt >= 33)
            ? Permission.photos
            : Permission.storage;
        var granted = await permission.status;
        if (!granted.isGranted) {
          var b = await permission.request();
          if (!b.isGranted) {
            _showPermissionDenied(context);
            return;
          }
        }
      }
    } catch (e) {}
  }

  _showPermissionDenied(BuildContext context) async {
    if (Prefer.getBool("storage_permission_denied") == true) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(I18n.of(context).storage_permission_denied),
      action: SnackBarAction(
        label: I18n.of(context).dont_show_again,
        onPressed: () {
          Prefer.setBool("storage_permission_denied", true);
        },
      ),
    ));
  }

  @override
  void dispose() {
    _intentDataStreamSubscription.cancel();
    _pageController.dispose();
    _sub.cancel();
    super.dispose();
  }

  initPlatformState() async {
    if (Prefer.getBool('guide_enable') == null) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => GuidePage()),
        (route) => false,
      );
      return;
    }
    initPermission(context);
  }
}

// 用来实现退出全屏功能的FAB
class AnimatedToggleFullscreenFAB extends StatefulWidget {
  final bool isFullscreen;
  final Function toggleFullscreen;

  const AnimatedToggleFullscreenFAB({
    Key? key,
    required this.isFullscreen,
    required this.toggleFullscreen,
  }) : super(key: key);

  @override
  _AnimatedToggleFullscreenFABState createState() =>
      _AnimatedToggleFullscreenFABState();
}

class _AnimatedToggleFullscreenFABState
    extends State<AnimatedToggleFullscreenFAB>
    with SingleTickerProviderStateMixin {
  // 用动画实现滑动出现效果
  late Animation<Offset> _offsetAnimation = Tween<Offset>(
    begin: const Offset(0.0, 4.0),
    end: Offset.zero,
  ).animate(CurvedAnimation(
    parent: _controller,
    curve: Curves.linear,
  ));
  late AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 400),
    vsync: this,
  );

  @override
  void didUpdateWidget(covariant AnimatedToggleFullscreenFAB oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isFullscreen != widget.isFullscreen) {
      if (widget.isFullscreen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: widget.isFullscreen,
      child: SlideTransition(
        position: _offsetAnimation,
        child: SizedBox(
            child: FloatingActionButton(
          onPressed: () {
            widget.toggleFullscreen();
          },
          child: Container(
              child: Icon(
            Icons.close_fullscreen,
          )),
        )),
      ),
    );
  }
}
