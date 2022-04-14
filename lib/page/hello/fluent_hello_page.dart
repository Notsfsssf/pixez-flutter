import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/constants.dart';
import 'package:pixez/custom_icon.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/page/Init/guide_page.dart';
import 'package:pixez/page/hello/new/new_page.dart';
import 'package:pixez/page/hello/ranking/rank_page.dart';
import 'package:pixez/page/hello/recom/recom_spotlight_page.dart';
import 'package:pixez/page/hello/setting/setting_page.dart';
import 'package:pixez/page/picture/illust_lighting_page.dart';
import 'package:pixez/page/preview/preview_page.dart';
import 'package:pixez/page/saucenao/sauce_store.dart';
import 'package:pixez/page/search/result_page.dart';
import 'package:pixez/page/search/search_page.dart';
import 'package:pixez/page/search/suggest/suggestion_store.dart';
import 'package:pixez/page/soup/soup_page.dart';
import 'package:pixez/page/user/users_page.dart';
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
    SearchPage(),
  ];
  List<_WidgetHistoryItem> _history =
      List<_WidgetHistoryItem>.empty(growable: true);
  int pageIndex = 0;
  int _lastPage = 0;

  push({
    required Widget icon,
    required Widget title,
    required Widget child,
    bool focus = true,
  }) {
    setState(
      () {
        if (_history.isEmpty) _lastPage = pageIndex;
        _history.add(_WidgetHistoryItem(icon, title, child));
        if (focus) pageIndex = _pageLists.length + _history.length - 1;
      },
    );
  }

  pop({
    int? index,
    Widget? content,
  }) {
    setState(() {
      if (index != null) {
        _history.removeAt(index);
      } else if (content != null) {
        _history.remove(
          _history.lastWhere((element) => element.content == content),
        );
      } else {
        if (_history.length < 2)
          pageIndex = _lastPage;
        else
          pageIndex = _pageLists.length + _history.length - 2;
        _history.removeLast();
      }
    });
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
    _initSearch();
  }

  Future<void> initPlatformState() async {
    var prefs = await SharedPreferences.getInstance();
    if (prefs.getInt('language_num') == null) {
      Leader.dialog(context, GuidePage());
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
        icon: Icon(FluentIcons.home),
        title: Text(I18n.of(context).home),
      ),
      PaneItem(
          icon: Icon(CustomIcons.leaderboard),
          title: Text(I18n.of(context).rank)),
      PaneItem(
        icon: Icon(FluentIcons.bookmarks),
        title: Text(I18n.of(context).quick_view),
      ),
      PaneItem(
        icon: Icon(FluentIcons.search),
        title: Text(I18n.of(context).search),
      ),
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
          key: GlobalKey(debugLabel: 'Search_AutoSuggestBox'),
          items: _suggestList,
          controller: _filter,
          onChanged: _onAutoSuggestBoxChanged,
          onSelected: _onAutoSuggestBoxSelected,
          placeholder: I18n.of(context).search,
          trailingIcon: IconButton(
            icon: Icon(FluentIcons.search),
            onPressed: () {},
          ),
        ),
        autoSuggestBoxReplacement: const Icon(FluentIcons.search),
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
          ..._history.map((e) => e.content),
          SettingPage(),
        ],
      ),
    );
  }

  _onAutoSuggestBoxChanged(String text, TextChangedReason reason) {
    if (reason == TextChangedReason.suggestionChosen) {
      _filter.text = '';
      return;
    }
    _suggestList = List.empty(growable: true);
    if (text.isEmpty || text == '') return;

    final id = int.tryParse(text);
    if (id != null) {
      print('int.tryParse(text)');
      _suggestList.addAll([
        "${I18n.of(context).illust_id}: ${id}",
        "${I18n.of(context).painter_id}: ${id}",
        "Pixivision Id: ${id}",
      ]);
    }
    if (_suggestionStore.autoWords?.tags.isNotEmpty ?? false) {
      print('_suggestionStore.autoWords?.tags.isNotEmpty ?? false');
      _suggestList.addAll(_suggestionStore.autoWords!.tags
          .map((e) => "${e.name} \n ${e.translated_name}"));
    }
    setState(() {});
  }

  _onAutoSuggestBoxSelected(String text) {
    if (text.startsWith('${I18n.of(context).illust_id}: ')) {
      final id = int.tryParse(
          text.replaceFirst('${I18n.of(context).illust_id}: ', ''));
      if (id != null)
        Leader.fluentNav(
          context,
          Icon(FluentIcons.image_pixel),
          Text('图片 ${id}'),
          IllustLightingPage(
            id: id,
          ),
        );
    } else if (text.startsWith('${I18n.of(context).painter_id}: ')) {
      final id = int.tryParse(
          text.replaceFirst('${I18n.of(context).painter_id}: ', ''));
      if (id != null)
        Leader.fluentNav(
          context,
          Icon(FluentIcons.image_pixel),
          Text('用户 ${id}'),
          UsersPage(
            id: id,
          ),
        );
    } else if (text.startsWith('Pixivision Id: ')) {
      final id = int.tryParse(text.replaceFirst('Pixivision Id: ', ''));
      if (id != null)
        Leader.fluentNav(
          context,
          Icon(FluentIcons.image_pixel),
          Text('Pixivision ${id}'),
          SoupPage(
            url: "https://www.pixivision.net/zh/a/${id}",
            spotlight: null,
          ),
        );
    } else {
      final raw = text.split('\n');
      final query = raw[0].trim();
      final translated_name = raw.length > 1 ? raw[1].trim() : '';
      if (tagGroup.length > 1) {
        tagGroup.last = query;
        var text = tagGroup.join(" ");
        _filter.text = text;
        _filter.selection =
            TextSelection.fromPosition(TextPosition(offset: text.length));
        setState(() {});
      } else {
        FocusScope.of(context).unfocus();
        Leader.fluentNav(
          context,
          Icon(FluentIcons.search),
          Text('搜索 ${query}'),
          ResultPage(
            word: query,
            translatedName: translated_name,
          ),
        );
      }
    }
  }

  late TextEditingController _filter;
  late SuggestionStore _suggestionStore;
  late SauceStore _sauceStore;
  FocusNode focusNode = FocusNode();
  final tagGroup = [];
  bool idV = false;
  _initSearch() {
    _suggestionStore = SuggestionStore();
    _sauceStore = SauceStore();
    _sauceStore.observableStream.listen((event) {
      if (event != null && _sauceStore.results.isNotEmpty) {
        Leader.fluentNav(
            context,
            Icon(FluentIcons.search),
            Text("搜索"),
            PageView(
              children: _sauceStore.results
                  .map((element) => IllustLightingPage(id: element))
                  .toList(),
            ));
      } else {
        BotToast.showText(text: "0 result");
      }
    });
    var query = '';
    _filter = TextEditingController(text: query);
    var tags = query
        .split(" ")
        .map((e) => e.trim())
        .takeWhile((value) => value.isNotEmpty);
    if (tags.length > 1) tagGroup.addAll(tags);
  }

  @override
  void dispose() {
    _sub.cancel();
    _pageController.dispose();
    _filter.dispose();
    _sauceStore.dispose();
    super.dispose();
  }
}

class _WidgetHistoryItem {
  final Widget icon;
  final Widget title;
  final Widget content;
  _WidgetHistoryItem(this.icon, this.title, this.content);
}
