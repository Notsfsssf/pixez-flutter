import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/component/fluent/pixiv_image.dart';
import 'package:pixez/constants.dart';
import 'package:pixez/custom_icon.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/page/fluent/Init/guide_page.dart';
import 'package:pixez/page/fluent/account/select/account_select_page.dart';
import 'package:pixez/page/fluent/follow/follow_list.dart';
import 'package:pixez/page/fluent/hello/new/illust/new_illust_page.dart';
import 'package:pixez/page/fluent/hello/new/new_page.dart';
import 'package:pixez/page/fluent/hello/ranking/rank_page.dart';
import 'package:pixez/page/fluent/hello/recom/recom_spotlight_page.dart';
import 'package:pixez/page/fluent/hello/setting/setting_page.dart';
import 'package:pixez/page/picture/illust_lighting_page.dart';
import 'package:pixez/page/fluent/preview/preview_page.dart';
import 'package:pixez/page/saucenao/sauce_store.dart';
import 'package:pixez/page/fluent/search/result_page.dart';
import 'package:pixez/page/search/suggest/suggestion_store.dart';
import 'package:pixez/page/fluent/soup/soup_page.dart';
import 'package:pixez/page/fluent/user/bookmark/bookmark_page.dart';
import 'package:pixez/page/fluent/user/users_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

class FluentHelloPage extends StatefulWidget {
  @override
  FluentHelloPageState createState() => FluentHelloPageState();
}

class FluentHelloPageState extends State<FluentHelloPage> with WindowListener {
  late StreamSubscription _sub;
  late int index;
  late PageController _pageController;
  static FluentHelloPageState? state;
  // 搜索建议列表
  final List<AutoSuggestBoxItem> _suggestList = List.empty(growable: true);
  final TextEditingController _filter = TextEditingController();
  final SuggestionStore _suggestionStore = SuggestionStore();
  final SauceStore _sauceStore = SauceStore();
  final FocusNode focusNode = FocusNode();
  final tagGroup = [];

  late PixEzNavigatorObserver _navobs;
  late Navigator _nav;
  final BookmarkPageMethodRelay relay = BookmarkPageMethodRelay();

  late List<_PixEzPageItem> _pages;
  late List<_PixEzPageItem> _lastpages;

  /// 空视图
  final _empty = Container();

  /// 推送路由到视图
  /// FluentUI的跳页功能
  Future<T?> push<T extends Object?>(
    BuildContext context,
    PixEzPageRoute<T> route,
  ) {
    assert(_navobs.navigator != null);
    setState(() => index = getItemCount(_pages));
    return _navobs.navigator!.push(route);
  }

  @override
  void initState() {
    state = this;
    _initSearch();
    Constants.type = 0;
    fetcher.context = context;
    index = userSetting.welcomePageNum;
    _pageController = PageController(initialPage: userSetting.welcomePageNum);
    super.initState();
    saveStore.ctx = this.context;
    saveStore.saveStream.listen((stream) {
      saveStore.listenBehavior(stream);
    });
    initPlatformState();
    _navobs = PixEzNavigatorObserver(
      _changeIndexWhenGoBack,
      _changeIndexWhenGo,
    );
    _nav = Navigator(
      key: GlobalKey<NavigatorState>(debugLabel: 'Navigator'),
      observers: [_navobs],
      onGenerateRoute: (settings) {
        final widget = _getPage(index);
        return PixEzPageRoute(
          builder: (context) => widget,
          index: index,
          settings: settings,
        );
      },
    );
    _pages = [
      _PixEzPageItem(
        (context) => const Icon(FluentIcons.home),
        (context) => Text(I18n.of(context).home),
        Observer(builder: (context) {
          if (accountStore.now != null)
            return RecomSpolightPage();
          else
            return PreviewPage();
        }),
      ),
      _PixEzPageItem(
        (context) => const Icon(CustomIcons.leaderboard),
        (context) => Text(I18n.of(context).rank),
        Observer(builder: (context) {
          if (accountStore.now != null)
            return RankPage();
          else
            return PreviewPage();
        }),
      ),
      _PixEzPageItem(
        (context) => const Icon(FluentIcons.bookmarks),
        (context) => Text(I18n.of(context).quick_view),
        NewPage(relay: relay),
        items: [
          _PixEzPageItem(
            (context) => const Icon(FluentIcons.news),
            (context) => Text(I18n.of(context).news),
            const NewIllustPage(),
          ),
          _PixEzPageItem(
            (context) => const Icon(FluentIcons.bookmarks),
            (context) => Text(I18n.of(context).bookmark),
            Observer(builder: (context) {
              if (accountStore.now != null)
                return BookmarkPage(
                    relay: relay,
                    isNested: false,
                    id: int.parse(accountStore.now!.userId));
              else
                return PreviewPage();
            }),
          ),
          _PixEzPageItem(
            (context) => const Icon(FluentIcons.follow_user),
            (context) => Text(I18n.of(context).followed),
            Observer(builder: (context) {
              if (accountStore.now != null)
                return FollowList(
                  id: int.parse(accountStore.now!.userId),
                );
              else
                return PreviewPage();
            }),
          ),
        ],
      ),
    ];
    _lastpages = [
      _PixEzPageItem(
        (context) => const Icon(FluentIcons.settings),
        (context) => Text(I18n.of(context).setting),
        const SettingPage(),
      ),
      _PixEzPageItem(
        (context) => SizedBox(
          height: 24,
          width: 24,
          child: CircleAvatar(
            backgroundImage: PixivProvider.url(
              accountStore.now?.userImage ??
                  'https://s.pximg.net/common/images/no_profile.png',
              preUrl: 'https://s.pximg.net/common/images/no_profile.png',
            ),
            radius: 100.0,
            backgroundColor: FluentTheme.of(context).accentColor,
          ),
        ),
        (context) => Text(accountStore.now?.name ?? 'Account'),
        AccountSelectPage(),
      ),
    ];
  }

  @override
  void dispose() {
    _sub.cancel();
    _pageController.dispose();
    super.dispose();
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
    return NavigationView(
      appBar: _buildAppBar(context),
      pane: _buildPane(context),
      paneBodyBuilder: (item, widget) => Listener(
        child: _nav,
        onPointerDown: (event) {
          if (event.buttons == kBackMouseButton &&
              event.kind == PointerDeviceKind.mouse) {
            _navobs.navigator?.maybePop(context);
          }
        },
      ),
    );
  }

  NavigationAppBar _buildAppBar(BuildContext context) {
    const height = 40.0;

    return NavigationAppBar(
      height: height,
      title: DragToMoveArea(
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: _navobs.current?.title ?? const Text('Pixez'),
        ),
      ),
      leading: PaneItem(
        icon: const Icon(FluentIcons.back, size: 14.0),
        title: Text(FluentLocalizations.of(context).backButtonTooltip),
        body: _empty,
        enabled: _navobs.canGoBack,
      ).build(
        context,
        false,
        () => _navobs.navigator?.maybePop(context),
        displayMode: PaneDisplayMode.compact,
      ),
      actions: SizedBox(
        width: 138,
        height: height,
        child: WindowCaption(
          brightness: FluentTheme.of(context).brightness,
          backgroundColor: Colors.transparent,
        ),
      ),
    );
  }

  NavigationPane _buildPane(BuildContext context) {
    return NavigationPane(
      // displayMode: PaneDisplayMode.top,
      // 太丑了 不加了
      // header: Row(
      //   children: [
      //     Image.asset(
      //       'assets/images/icon.png',
      //       height: 48,
      //       width: 48,
      //     ),
      //     Container(
      //       margin: EdgeInsets.only(left: 8.0),
      //       child: Column(
      //         crossAxisAlignment: CrossAxisAlignment.start,
      //         mainAxisAlignment: MainAxisAlignment.center,
      //         children: [
      //           Text(
      //             'PixEz',
      //             style: FluentTheme.of(context).typography.bodyStrong,
      //           ),
      //           Text('Your Favorite Pixiv Client!')
      //         ],
      //       ),
      //     ),
      //   ],
      // ),
      autoSuggestBox: AutoSuggestBox(
        items: _suggestList,
        controller: _filter,
        onChanged: _onAutoSuggestBoxChanged,
        placeholder: I18n.of(context).search,
        leadingIcon: IconButton(
          icon: const Icon(FluentIcons.image_search),
          onPressed: _searchFromImage,
        ),
        trailingIcon: IconButton(
          icon: const Icon(FluentIcons.search),
          onPressed: () {
            Leader.push(
              context,
              ResultPage(word: _filter.text),
              icon: const Icon(FluentIcons.search),
              title: Text('搜索 ${_filter.text}'),
            );
          },
        ),
      ),
      selected: index,
      onChanged: _changedPage,
      items: [
        ..._itemsBuilder(context, _pages),
        if (_navobs.current != null && _navobs.current!.index == null) ...[
          PaneItemSeparator(),
          PaneItem(
            icon: _navobs.current?.icon ?? const Icon(FluentIcons.unknown),
            title: _navobs.current?.title ?? Text(I18n.of(context).undefined),
            body: _empty,
          )
        ],
      ],
      footerItems: _itemsBuilder(context, _lastpages),
    );
  }

  List<NavigationPaneItem> _itemsBuilder(
      BuildContext context, List<_PixEzPageItem> source) {
    return source.map((i) {
      if (i.items.isNotEmpty) {
        return PaneItemExpander(
          icon: i.icon(context),
          items: _itemsBuilder(context, i.items),
          body: _empty,
          title: i.title(context),
        );
      } else {
        return PaneItem(
          icon: i.icon(context),
          body: _empty,
          title: i.title(context),
        );
      }
    }).toList();
  }

  int getItemCount(List<_PixEzPageItem> items) => items
      .map((i) => getItemCount(i.items))
      .fold(items.length, (value, element) => value + element);

  List<_PixEzPageItem> _many(List<_PixEzPageItem> items) {
    List<_PixEzPageItem> result = List.empty(growable: true);
    items.forEach((i) {
      result.add(i);
      result.addAll(_many(i.items));
    });
    return result;
  }

  _initSearch() {
    _sauceStore.observableStream.listen((event) {
      if (event != null && _sauceStore.results.isNotEmpty) {
        Leader.push(
          context,
          PageView(
            children: _sauceStore.results
                .map((element) => IllustLightingPage(id: element))
                .toList(),
          ),
          icon: Icon(FluentIcons.search),
          title: Text("搜索"),
        );
      } else {
        BotToast.showText(text: "0 result");
      }
    });
    var query = '';
    var tags = query
        .split(" ")
        .map((e) => e.trim())
        .takeWhile((value) => value.isNotEmpty);
    if (tags.length > 1) tagGroup.addAll(tags);
  }

  AutoSuggestBoxItem _getItemByIllustId(int id) {
    final text = '${I18n.of(context).illust_id}: ${id}';
    return AutoSuggestBoxItem(
      label: text,
      value: id,
      onSelected: () => Leader.push(
        context,
        IllustLightingPage(id: id),
        icon: const Icon(FluentIcons.image_pixel),
        title: Text(text),
      ),
    );
  }

  AutoSuggestBoxItem _getItemByPainterId(int id) {
    final text = '${I18n.of(context).painter_id}: ${id}';
    return AutoSuggestBoxItem(
      label: text,
      value: id,
      onSelected: () => Leader.push(
        context,
        UsersPage(id: id),
        icon: const Icon(FluentIcons.image_pixel),
        title: Text(text),
      ),
    );
  }

  AutoSuggestBoxItem _getItemByPixivisionId(int id) {
    final text = 'Pixivision Id: ${id}';
    return AutoSuggestBoxItem(
      label: text,
      value: id,
      onSelected: () => Leader.push(
        context,
        SoupPage(
          url: "https://www.pixivision.net/zh/a/${id}",
          spotlight: null,
        ),
        icon: const Icon(FluentIcons.image_pixel),
        title: Text(text),
      ),
    );
  }

  _onAutoSuggestBoxChanged(String text, TextChangedReason reason) {
    if (reason == TextChangedReason.suggestionChosen) {
      _filter.text = '';
      return;
    }
    _suggestList.clear();
    if (text.isEmpty || text == '') return;

    final id = int.tryParse(text);
    if (id != null) {
      _suggestList.addAll([
        _getItemByIllustId(id),
        _getItemByPainterId(id),
        _getItemByPixivisionId(id),
      ]);
    }
    if (_suggestionStore.autoWords?.tags.isNotEmpty ?? false) {
      _suggestList.addAll(_suggestionStore.autoWords!.tags.map((e) {
        var text = e.name;
        if (e.translated_name != null) text += "\n ${e.translated_name}";
        return AutoSuggestBoxItem(
          label: text,
          value: e.name,
          onSelected: () {
            if (tagGroup.length > 1) {
              tagGroup.last = e.name;
              var text = tagGroup.join(" ");
              _filter.text = text;
              _filter.selection =
                  TextSelection.fromPosition(TextPosition(offset: text.length));
              setState(() {});
            } else {
              FocusScope.of(context).unfocus();
              Leader.push(
                context,
                ResultPage(
                  word: e.name,
                  translatedName: e.translated_name ?? '',
                ),
                icon: Icon(FluentIcons.search),
                title: Text('${I18n.of(context).search}: ${text}'),
              );
            }
          },
        );
      }));
    }
  }

  int _getIndex(int? index) => index ?? getItemCount(_pages);

  /// 切换页面
  void _changedPage(int index) {
    if (_navobs.current?.index == null && index > getItemCount(_pages)) index--;

    assert(index < getItemCount(_pages) + getItemCount(_lastpages));

    setState(() => this.index = index);

    final widget = _getPage(index);

    assert(_navobs.navigator != null);
    _navobs.navigator!.push(PixEzPageRoute(
      builder: (context) => widget,
      index: index,
    ));
  }

  void _changeIndexWhenGo(PixEzPageRoute route, PixEzPageRoute? previousRoute) {
    debugPrint('Go');
    this.index = _getIndex(route.index);
    try {
      setState(() {});
    } catch (err) {
      debugPrint(err.toString());
    }
  }

  /// 当导航器弹出时重设索引值
  void _changeIndexWhenGoBack(
      PixEzPageRoute route, PixEzPageRoute? previousRoute) {
    debugPrint('GoBack');
    try {
      setState(() {
        this.index = _getIndex(previousRoute?.index);
      });
    } catch (err) {
      debugPrint(err.toString());
    }
  }

  /// 根据index获取不同页
  Widget _getPage(int index) => index >= getItemCount(_pages)
      ? _many(_lastpages)[index - getItemCount(_pages)].page
      : _many(_pages)[index].page;

  _searchFromImage() {
    _sauceStore.findImage();
  }
}

class _PixEzPageItem {
  final Widget Function(BuildContext) icon;
  final Widget Function(BuildContext) title;
  final Widget page;
  final List<_PixEzPageItem> items;

  _PixEzPageItem(this.icon, this.title, this.page,
      {this.items = const <_PixEzPageItem>[]});
}

class PixEzPageRoute<T> extends FluentPageRoute<T> {
  /// 当前活动的项目的索引
  /// 当 == null 时使用 icon 和 title 创建项目
  final int? index;
  final Widget? icon;
  final Widget? title;

  PixEzPageRoute({
    required super.builder,
    this.icon,
    this.title,
    this.index,
    super.maintainState,
    super.barrierLabel,
    super.settings,
    super.fullscreenDialog = false,
  }) {
    if (index == null) {
      if (icon == null || title == null) {
        // 必须设置 index 或 icon、title。
        throw new Exception('You MUST set index or icon and title.');
      }
    } else {
      if (icon != null || title != null) {
        // 设置 index 后不可以设置 icon、title。
        throw new Exception(
            'You MUST NOT set icon and title when you have index.');
      }
    }
  }
}

/// PixEzNavigatorObserver 控制着整个应用的页面的呈现逻辑和后退历史逻辑
class PixEzNavigatorObserver extends NavigatorObserver {
  final List<PixEzPageRoute> _histories = List.empty(growable: true);
  final void Function(PixEzPageRoute, PixEzPageRoute?) onPop;
  final void Function(PixEzPageRoute, PixEzPageRoute?) onPush;

  PixEzNavigatorObserver(this.onPop, this.onPush);

  /// 当前的页面
  PixEzPageRoute? get current => _histories.isEmpty ? null : _histories.last;

  /// 决定窗口左上角后退按钮是否允许用户点击
  bool get canGoBack => _histories.length > 1 && (navigator?.canPop() ?? false);

  /// 当有新的页面被推入时被激活
  @override
  void didPush(Route route, Route? previousRoute) {
    if (route is PixEzPageRoute) {
      _histories.add(route);
      onPush(route, previousRoute as PixEzPageRoute?);
    }
  }

  /// 当有新的页面被弹出时被激活
  @override
  void didPop(Route route, Route? previousRoute) {
    if (route is PixEzPageRoute) {
      _histories.removeLast();
      onPop(route, previousRoute as PixEzPageRoute?);
    }
  }
}
