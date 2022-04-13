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
import 'package:pixez/page/hello/setting/setting_page.dart';
import 'package:pixez/page/preview/preview_page.dart';
import 'package:pixez/widgetkit_plugin.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FluentHelloPage extends StatefulWidget {
  @override
  FluentHelloPageState createState() => FluentHelloPageState();

  static FluentHelloPageState of(
    BuildContext context, {
    bool root = false,
  }) {
    FluentHelloPageState? state;
    if (context is StatefulElement && context.state is FluentHelloPageState) {
      state = context.state as FluentHelloPageState;
    }
    if (root) {
      state =
          context.findRootAncestorStateOfType<FluentHelloPageState>() ?? state;
    } else {
      state = state ?? context.findAncestorStateOfType<FluentHelloPageState>();
    }

    assert(() {
      if (state == null) {
        throw FlutterError(
          'FluentHelloPage operation requested with a context that does not include a FluentHelloPage.\n'
          'The context used to push or pop routes from the FluentHelloPage must be that of a '
          'widget that is a descendant of a FluentHelloPage widget.',
        );
      }
      return true;
    }());
    return state!;
  }
}

class FluentHelloPageState extends State<FluentHelloPage> {
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
  List<_WidgetHistoryItem> _history =
      List<_WidgetHistoryItem>.empty(growable: true);
  int pageIndex = 0;
  int _lastPage = 0;

  push({
    required Widget icon,
    required Widget title,
    required Widget child,
  }) {
    setState(
      () {
        if (_history.isEmpty) _lastPage = pageIndex;
        _history.add(_WidgetHistoryItem(icon, title, child));
        pageIndex = _pageLists.length + _history.length - 1;
      },
    );
  }

  pop() {
    setState(() {
      _history.removeLast();
      if (_history.isEmpty)
        pageIndex = _lastPage;
      else
        pageIndex = _pageLists.length + _history.length - 1;
    });
  }

  popAt(int index) => setState(() => _history.removeAt(index));
  popWith(Widget widget) {
    setState(
      () => _history.remove(
        _history.lastWhere((element) => element.widget == widget),
      ),
    );
  }

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
      // 登录部分
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

    if (_history.isNotEmpty) {
      items.addAll([
        PaneItemSeparator(),
        ..._history.map(
          (e) => PaneItem(
            icon: e.icon,
            title: e.title,
          ),
        )
      ]);
    }

    return NavigationView(
      pane: NavigationPane(
        header: Stack(alignment: AlignmentDirectional.centerStart, children: [
          Container(
            alignment: Alignment.center,
            child: Text('Pixez'),
          ),
          IconButton(
            icon: Icon(FluentIcons.back),
            onPressed: _history.isEmpty ? null : pop,
            style: ButtonStyle(
              backgroundColor: _history.isNotEmpty
                  ? null
                  : ButtonState.all(Colors.transparent),
            ),
          )
        ]),
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
          ..._history.map((e) => e.widget),
          SettingPage(),
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

class _WidgetHistoryItem {
  final Widget icon;
  final Widget title;
  final Widget widget;
  _WidgetHistoryItem(this.icon, this.title, this.widget);
}
