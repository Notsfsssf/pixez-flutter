import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/er/prefer.dart';
import 'package:pixez/fluent/component/pixez_global_shortkey_listener.dart';
import 'package:pixez/fluent/component/pixiv_image.dart';
import 'package:pixez/constants.dart';
import 'package:pixez/custom_icon.dart';
import 'package:pixez/fluent/component/search_box/pixez_search_box.dart';
import 'package:pixez/fluent/navigation/pixez_page_history_manager.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/fluent/page/Init/guide_page.dart';
import 'package:pixez/fluent/page/follow/follow_list.dart';
import 'package:pixez/fluent/page/hello/new/illust/new_illust_page.dart';
import 'package:pixez/fluent/page/hello/ranking/rank_page.dart';
import 'package:pixez/fluent/page/hello/recom/recom_spotlight_page.dart';
import 'package:pixez/fluent/page/hello/setting/setting_page.dart';
import 'package:pixez/fluent/page/login/login_page.dart';
import 'package:pixez/fluent/page/preview/preview_page.dart';
import 'package:pixez/fluent/page/user/bookmark/bookmark_page.dart';
import 'package:pixez/fluent/page/user/users_page.dart';
import 'package:window_manager/window_manager.dart';

class FluentHelloPage extends StatefulWidget {
  @override
  FluentHelloPageState createState() => FluentHelloPageState();
}

class FluentHelloPageState extends State<FluentHelloPage> with WindowListener {
  late StreamSubscription _sub;
  late PageController _pageController;
  PaneItemExpanderKey _expandedKey = PaneItemExpanderKey();

  final BookmarkPageMethodRelay relay = BookmarkPageMethodRelay();

  @override
  void initState() {
    Constants.type = 0;
    fetcher.context = context;
    PixEzPageHistoryManager.init(
      initIndex: userSetting.welcomePageNum,
      floatIndex: 6,
      skipIndexes: [2],
      refresh: () => setState(() {}),
    );

    _pageController = PageController(initialPage: userSetting.welcomePageNum);
    super.initState();
    saveStore.ctx = this.context;
    saveStore.saveStream.listen((stream) {
      saveStore.listenBehavior(stream);
    });
    initPlatformState();
  }

  @override
  void dispose() {
    _sub.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> initPlatformState() async {
    if (Prefer.getInt('language_num') == null) {
      Navigator.of(context)
          .pushReplacement(FluentPageRoute(builder: (context) => GuidePage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return PixEzGlobalShortkeyListener(
      child: NavigationView(
        appBar: _buildAppBar(context),
        pane: _buildPane(context),
      ),
      goBack: PixEzPageHistoryManager.pop,
    );
  }

  NavigationAppBar _buildAppBar(BuildContext context) {
    const height = 40.0;

    return NavigationAppBar(
      height: height,
      title: DragToMoveArea(
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: PixEzPageHistoryManager.current?.title ?? const Text('Pixez'),
        ),
      ),
      leading: PaneItem(
        icon: const Icon(FluentIcons.back, size: 14.0),
        title: Text(FluentLocalizations.of(context).backButtonTooltip),
        body: const Text(''),
        enabled: PixEzPageHistoryManager.canGoBack,
      ).build(
        context,
        false,
        PixEzPageHistoryManager.pop,
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
    final dynamicItem = PixEzPageHistoryManager.current;
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
      autoSuggestBox: PixEzSearchBox(),
      selected: PixEzPageHistoryManager.currentIndex,
      onChanged: PixEzPageHistoryManager.pushIndex,
      items: [
        PaneItem(
          icon: const Icon(FluentIcons.home),
          title: Text(I18n.of(context).home),
          body: Observer(builder: (context) {
            if (accountStore.now != null)
              return RecomSpolightPage();
            else
              return PreviewPage();
          }),
        ),
        PaneItem(
          icon: const Icon(CustomIcons.leaderboard),
          title: Text(I18n.of(context).rank),
          body: Observer(builder: (context) {
            if (accountStore.now != null)
              return RankPage();
            else
              return PreviewPage();
          }),
        ),
        PaneItemExpander(
          key: _expandedKey,
          icon: const Icon(FluentIcons.bookmarks),
          title: Text(I18n.of(context).quick_view),
          body: const Text(''),
          onTap: () => _expandedKey.currentState?.toggleOpen(),
          items: [
            PaneItem(
              icon: const Icon(FluentIcons.news),
              title: Text(I18n.of(context).news),
              body: const NewIllustPage(),
            ),
            PaneItem(
              icon: const Icon(FluentIcons.bookmarks),
              title: Text(I18n.of(context).bookmark),
              body: Observer(builder: (context) {
                if (accountStore.now != null)
                  return BookmarkPage(
                      relay: relay,
                      isNested: false,
                      id: int.parse(accountStore.now!.userId));
                else
                  return PreviewPage();
              }),
            ),
            PaneItem(
              icon: const Icon(FluentIcons.follow_user),
              title: Text(I18n.of(context).followed),
              body: Observer(builder: (context) {
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
        if (dynamicItem != null) ...[
          PaneItemSeparator(),
          PaneItem(
            icon: dynamicItem.icon,
            title: dynamicItem.title,
            body: Navigator(
              observers: [PixEzPageHistoryManager.observer],
              onGenerateRoute: (settings) {
                return FluentPageRoute(
                  builder: (context) => const Text(''),
                  settings: settings,
                );
              },
            ),
          )
        ],
      ],
      footerItems: [
        PaneItem(
          icon: const Icon(FluentIcons.settings),
          title: Text(I18n.of(context).setting),
          body: const SettingPage(),
        ),
        PaneItem(
          icon: SizedBox(
            height: 24,
            width: 24,
            child: Observer(
              builder: (context) => CircleAvatar(
                backgroundImage: PixivProvider.url(
                  accountStore.now?.userImage ??
                      'https://s.pximg.net/common/images/no_profile.png',
                  preUrl: 'https://s.pximg.net/common/images/no_profile.png',
                ),
                radius: 100.0,
                backgroundColor: FluentTheme.of(context).accentColor,
              ),
            ),
          ),
          title: Text(accountStore.now?.name ?? 'Account'),
          body: Builder(
            builder: (context) => accountStore.now != null
                ? UsersPage(id: int.parse(accountStore.now!.userId))
                : LoginPage(),
          ),
        ),
      ],
    );
  }
}
