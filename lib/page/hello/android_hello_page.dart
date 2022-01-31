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

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pixez/constants.dart';
import 'package:pixez/custom_icon.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/er/lprinter.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/lighting/lighting_store.dart';
import 'package:pixez/main.dart';
import 'package:pixez/page/Init/guide_page.dart';
import 'package:pixez/page/hello/new/new_page.dart';
import 'package:pixez/page/hello/ranking/rank_page.dart';
import 'package:pixez/page/hello/recom/recom_spotlight_page.dart';
import 'package:pixez/page/hello/setting/setting_page.dart';
import 'package:pixez/page/login/login_page.dart';
import 'package:pixez/page/saucenao/saucenao_page.dart';
import 'package:pixez/page/search/search_page.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_links2/uni_links.dart';

import 'ranking/rank_store.dart';

class AndroidHelloPage extends StatefulWidget {
  final LightingStore? lightingStore;

  const AndroidHelloPage({Key? key, this.lightingStore}) : super(key: key);

  @override
  _AndroidHelloPageState createState() => _AndroidHelloPageState();
}

class _AndroidHelloPageState extends State<AndroidHelloPage> {
  late List<Widget> _pageList;
  DateTime? _preTime;

  // key 用来获取高度以实现一些基础的动画
  GlobalKey bottomNavigatorKey = GlobalKey();
  double? bottomNavigatorHeight = null;

  ValueNotifier<bool> isFullscreen = ValueNotifier(false);

  void toggleFullscreen() {
    isFullscreen.value = !isFullscreen.value;
  }

  // 获取bottomNavigator的高度，方便实现基础的动画
  void initBottomNavigatorHeight() {
    Size? bottomNavigatorSize =
        bottomNavigatorKey.currentContext?.findRenderObject()?.paintBounds.size;
    print('bottomNavigatorSize is ' + bottomNavigatorSize.toString());
    if (bottomNavigatorSize != null) {
      setState(() {
        bottomNavigatorHeight = bottomNavigatorSize.height;
        print('get height is ' + bottomNavigatorSize.height.toString());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (!userSetting.isReturnAgainToExit) {
          return true;
        }
        if (_preTime == null ||
            DateTime.now().difference(_preTime!) > Duration(seconds: 2)) {
          _preTime = DateTime.now();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            duration: Duration(seconds: 1),
            content: Text(I18n.of(context).return_again_to_exit),
          ));
          // BotToast.showText(text: I18n.of(context).return_again_to_exit);
          return false;
        }
        return true;
      },
      child: Observer(builder: (context) {
        if (accountStore.now != null &&
            (Platform.isIOS || Platform.isAndroid)) {
          return _buildScaffold(context);
          // return LayoutBuilder(builder: (context, constraint) {
          //   if (constraint.maxHeight > constraint.maxWidth)
          //     return _buildPadScafford(context, constraint);
          //   return _buildScaffold(context);
          // });
        }
        return LoginPage();
      }),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    // 如果没有获取到底部导航的高度，在重新渲染的时候会尝试获取底部导航的高度
    if (bottomNavigatorHeight == null) {
      Timer(const Duration(milliseconds: 0), () {
        initBottomNavigatorHeight();
      });
    }
    return Scaffold(
        body: _buildPageContent(context),
        floatingActionButton: ValueListenableBuilder<bool>(
          valueListenable: isFullscreen,
          builder: (context, value, child) => AnimatedToggleFullscreenFAB(
            isFullscreen: value,
            toggleFullscreen: toggleFullscreen,
          ),
        ),
        bottomNavigationBar: ValueListenableBuilder<bool>(
            valueListenable: isFullscreen,
            builder: (BuildContext context, bool isFullscreen, Widget? child) =>
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  height: isFullscreen ? 0 : bottomNavigatorHeight,
                  key: bottomNavigatorKey,
                  child: BottomNavigationBar(
                      type: BottomNavigationBarType.fixed,
                      selectedItemColor: Theme.of(context).colorScheme.primary,
                      currentIndex: index,
                      onTap: (index) {
                        if (this.index == index) {
                          topStore.setTop("${index + 1}00");
                        }
                        setState(() {
                          this.index = index;
                        });
                        if (_pageController.hasClients)
                          _pageController.jumpToPage(index);
                      },
                      items: [
                        BottomNavigationBarItem(
                            icon: Icon(Icons.home),
                            label: I18n.of(context).home),
                        BottomNavigationBarItem(
                            icon: Icon(
                              CustomIcons.leaderboard,
                            ),
                            label: I18n.of(context).rank),
                        BottomNavigationBarItem(
                            icon: Icon(Icons.favorite),
                            label: I18n.of(context).quick_view),
                        BottomNavigationBarItem(
                            icon: Icon(Icons.search),
                            label: I18n.of(context).search),
                        BottomNavigationBarItem(
                            icon: Icon(Icons.more_horiz),
                            label: I18n.of(context).more),
                      ]),
                )));
  }

  Widget _buildPadScafford(BuildContext context, BoxConstraints constraint) {
    double radio = constraint.maxHeight / constraint.maxWidth;
    double width = radio * constraint.maxHeight;
    return Stack(children: [
      _buildScaffold(context),
      Container(
        width: width,
        child: Navigator(
          onGenerateRoute: (RouteSettings routeSettings) {
            return PageRouteBuilder(pageBuilder: (BuildContext context,
                Animation<double> animation,
                Animation<double> secondaryAnimation) {
              return Container();
            });
          },
        ),
      )
    ]);
  }

  Widget _buildPageContent(BuildContext context) {
    return PageView.builder(
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

  late int index;
  late PageController _pageController;
  late StreamSubscription _intentDataStreamSubscription;
  late StreamSubscription _textStreamSubscription;
  bool hasNewVersion = false;

  @override
  void initState() {
    fetcher.context = context;
    Constants.type = 0;
    _pageList = [
      RecomSpolightPage(lightingStore: widget.lightingStore),
      RankPage(
        isFullscreen: isFullscreen,
        toggleFullscreen: toggleFullscreen,
      ),
      NewPage(),
      SearchPage(),
      SettingPage()
    ];
    index = userSetting.welcomePageNum;
    _pageController = PageController(initialPage: index);
    super.initState();
    saveStore.context = this.context;
    saveStore.saveStream.listen((stream) {
      saveStore.listenBehavior(stream);
    });
    initPlatformState();
    _textStreamSubscription =
        ReceiveSharingIntent.getTextStreamAsUri().listen((uri) {
      Leader.pushWithUri(context, uri);
    });
    ReceiveSharingIntent.getInitialTextAsUri().then((value) {
      if (value != null) {
        Leader.pushWithUri(context, value);
      }
    });
    _intentDataStreamSubscription = ReceiveSharingIntent.getMediaStream()
        .listen((List<SharedMediaFile> value) {
      if (value != null)
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return SauceNaoPage(
            path: value.first.path,
          );
        }));
    }, onError: (err) {
      print("getIntentDataStream error: $err");
    });
    ReceiveSharingIntent.getInitialMedia().then((List<SharedMediaFile> value) {
      if (value != null && value.isNotEmpty)
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return SauceNaoPage(
            path: value.first.path,
          );
        }));
    });
    initPlatform();
    // 利用事件循环的顺序使UI初始化完毕后获取AppBar的高度
    Timer(const Duration(milliseconds: 0), () {
      initBottomNavigatorHeight();
    });
  }

  late StreamSubscription _sub;

  initPlatform() async {
    try {
      Uri? initialLink = await getInitialUri();
      if (initialLink != null) Leader.pushWithUri(context, initialLink);
      _sub = uriLinkStream
          .listen((Uri? link) => Leader.pushWithUri(context, link!));
    } catch (e) {
      print(e);
    }
  }

  initPermission() async {
    try {
      if (Platform.isAndroid && userSetting.saveMode != 1) {
        var granted = await Permission.storage.status;
        if (!granted.isGranted) {
          var b = await Permission.storage.request();
          if (!b.isGranted) {
            BotToast.showText(text: "storage permission denied");
            return;
          }
        }
      }
    } catch (e) {}
  }

  @override
  void dispose() {
    _intentDataStreamSubscription.cancel();
    _textStreamSubscription.cancel();
    _pageController.dispose();
    _sub.cancel();
    super.dispose();
  }

  initPlatformState() async {
    var prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('guide_enable') == null) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => GuidePage()),
        (route) => route == null,
      );
      return;
    }
    initPermission();
  }
}

// 用来实现退出全屏功能的FAB
class AnimatedToggleFullscreenFAB extends StatefulWidget {
  late bool isFullscreen;
  late Function toggleFullscreen;

  AnimatedToggleFullscreenFAB({
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
  Widget build(BuildContext context) {
    if (widget.isFullscreen) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    return SlideTransition(
      position: _offsetAnimation,
      child: SizedBox(
          height: 65,
          width: 65,
          child: FloatingActionButton(
            onPressed: () {
              widget.toggleFullscreen();
            },
            child: Container(
                child: Icon(
              Icons.close_fullscreen,
            )),
          )),
    );
  }
}
