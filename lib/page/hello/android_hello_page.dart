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
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pixez/constants.dart';
import 'package:pixez/document_plugin.dart';
import 'package:pixez/er/leader.dart';
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
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_links2/uni_links.dart';

class AndroidHelloPage extends StatefulWidget {
  const AndroidHelloPage({Key? key}) : super(key: key);

  @override
  _AndroidHelloPageState createState() => _AndroidHelloPageState();
}

class _AndroidHelloPageState extends State<AndroidHelloPage> {
  late List<Widget> _pageList;
  DateTime? _preTime;
  double? bottomNavigatorHeight = null;

  ValueNotifier<bool> isFullscreen = ValueNotifier(false);

  void toggleFullscreen() {
    isFullscreen.value = !isFullscreen.value;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        userSetting.setAnimContainer(!userSetting.animContainer);
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
          return false;
        }
        return true;
      },
      child: Observer(builder: (context) {
        if (accountStore.now != null &&
            (Platform.isIOS || Platform.isAndroid)) {
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
      }),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    if (bottomNavigatorHeight == null) {
      bottomNavigatorHeight = MediaQuery.of(context).padding.bottom + 80;
    }
    return Scaffold(
        body: _buildPageContent(context),
        extendBody: true,
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
                  child: _buildNavigationBar(context),
                )));
  }

  NavigationBar _buildNavigationBar(BuildContext context) {
    return NavigationBar(
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
    );
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
      RecomSpolightPage(),
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
    saveStore.ctx = this.context;
    saveStore.saveStream.listen((stream) {
      saveStore.listenBehavior(stream);
    });
    initPlatformState();
    _textStreamSubscription =
        ReceiveSharingIntent.getTextStream().listen((value) {
      _showChromeLink(value);
    });
    ReceiveSharingIntent.getInitialText().then((value) {
      if (value != null) {
        _showChromeLink(value);
      }
    });
    _intentDataStreamSubscription = ReceiveSharingIntent.getMediaStream()
        .listen((List<SharedMediaFile> value) {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) {
        return SauceNaoPage(
          path: value.first.path,
        );
      }));
    }, onError: (err) {
      print("getIntentDataStream error: $err");
    });
    ReceiveSharingIntent.getInitialMedia().then((List<SharedMediaFile> value) {
      if (value.isNotEmpty) {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return SauceNaoPage(
            path: value.first.path,
          );
        }));
      }
    });
    initPlatform();
  }

  VoidCallback? _LinkCloser = null;

  _showChromeLink(String link) {
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
        final info = await DeviceInfoPlugin().androidInfo;
        if (info.version.sdkInt >= 33) {
          final status = await DocumentPlugin.permissionStatus() ?? false;
          if (!status) {
            final grant = await DocumentPlugin.requestPermission();
            if (grant != true) {
              _showPermissionDenied();
            }
          }
        } else {
          var granted = await Permission.storage.status;
          if (!granted.isGranted) {
            var b = await Permission.storage.request();
            if (!b.isGranted) {
              _showPermissionDenied();
              return;
            }
          }
        }
      }
    } catch (e) {}
  }

  _showPermissionDenied() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool("permission_denied") == true) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("storage permission denied"),
      action: SnackBarAction(
        label: "Don't show again",
        onPressed: () {
          prefs.setBool("storaget_denied_confirm", true);
        },
      ),
    ));
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
