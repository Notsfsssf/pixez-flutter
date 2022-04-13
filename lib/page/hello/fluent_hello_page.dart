import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/constants.dart';
import 'package:pixez/custom_icon.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/page/Init/guide_page.dart';
import 'package:pixez/page/hello/new/new_page.dart';
import 'package:pixez/page/hello/ranking/rank_page.dart';
import 'package:pixez/page/hello/recom/recom_spotlight_page.dart';
import 'package:pixez/page/hello/setting/fluent_setting_page.dart';
import 'package:pixez/page/preview/preview_page.dart';
import 'package:pixez/widgetkit_plugin.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FluentHelloPage extends StatefulWidget {
  @override
  _FluentHelloPageState createState() => _FluentHelloPageState();
}

class _FluentHelloPageState extends State<FluentHelloPage> {
  late PageController _pageController;
  late StreamSubscription _sub;
  List<String> _suggestList = List.empty(growable: true);
  List<Widget> _pageLists = <Widget>[
    Observer(builder: (context) {
      if (accountStore.now != null)
        return RecomSpolightPage();
      else
        return PreviewPage();
    }),
    Observer(builder: (context) {
      if (accountStore.now != null)
        return RankPage();
      else
        return PreviewPage();
    }),
    NewPage(),
    // SearchPage(),
  ];
  int pageIndex = 0;

  @override
  void initState() {
    Constants.type = 0;
    fetcher.context = context;
    pageIndex = userSetting.welcomePageNum;
    _pageController = PageController(initialPage: userSetting.welcomePageNum);
    super.initState();
    saveStore.context = this.context;
    saveStore.saveStream.listen((stream) {
      saveStore.listenBehavior(stream);
    });
    initPlatformState();
    WidgetkitPlugin.notify();
  }

  Future<void> initPlatformState() async {
    var prefs = await SharedPreferences.getInstance();
    if (prefs.getInt('language_num') == null) {
      Navigator.of(context)
          .pushReplacement(FluentPageRoute(builder: (context) => GuidePage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      // TODO: 登录部分
      // if (accountStore.now != null) {
      return _buildNavigationView(context);
      // }
      // return FluentLoginPage();
    });
  }

  Widget _buildNavigationView(BuildContext context) {
    final items = List<NavigationPaneItem>.from(<NavigationPaneItem>[
      PaneItem(
          icon: Icon(FluentIcons.home), title: Text(I18n.of(context).home)),
      PaneItem(
          icon: Icon(CustomIcons.leaderboard),
          title: Text(I18n.of(context).rank)),
      PaneItem(
          icon: Icon(FluentIcons.bookmarks),
          title: Text(I18n.of(context).quick_view)),
      // PaneItem(
      //     icon: Icon(FluentIcons.search),
      //     title: Text(I18n.of(context).search)),
    ], growable: true);
    return NavigationView(
      pane: NavigationPane(
        header: Container(
          alignment: Alignment.center,
          child: Text('Pixez'),
        ),
        autoSuggestBox: AutoSuggestBox(
          items: _suggestList,
          onChanged: _onAutoSuggestBoxChanged,
          placeholder: 'Search...', // TODO: i18n
          trailingIcon: Icon(FluentIcons.search),
        ),
        items: items,
        footerItems: [
          PaneItemSeparator(),
          PaneItem(
              icon: Icon(FluentIcons.settings),
              title: Text(I18n.of(context).setting)),
        ],
        size: NavigationPaneSize(openMaxWidth: 250.0),
        selected: pageIndex,
        onChanged: (i) => setState(() => pageIndex = i),
      ),
      content: NavigationBody(
        index: pageIndex,
        children: [
          ..._pageLists,
          FluentSettingPage(),
        ],
      ),
    );
  }

  void _onAutoSuggestBoxChanged(String text, TextChangedReason reason) {}

  @override
  void dispose() {
    _sub.cancel();
    _pageController.dispose();
    super.dispose();
  }
}
