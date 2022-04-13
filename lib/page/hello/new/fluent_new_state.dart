import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/component/md2_tab_indicator.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/page/follow/follow_list.dart';
import 'package:pixez/page/hello/new/illust/new_illust_page.dart';
import 'package:pixez/page/hello/new/new_page.dart';
import 'package:pixez/page/preview/preview_page.dart';
import 'package:pixez/page/user/bookmark/bookmark_page.dart';
import 'package:pixez/page/user/users_page.dart';

class FluentNewPageState extends NewPageStateBase {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ScaffoldPage(
      content: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (accountStore.now != null)
      return _buildContentWithSignin(context);
    else
      return _buildContentWithoutSignin(context);
  }

  Widget _buildContentWithSignin(BuildContext context) {
    return TabView(
      onChanged: (i) => setState(() => _currentIndex = i),
      currentIndex: _currentIndex,
      footer: IconButton(
        icon: Icon(FluentIcons.account_browser),
        onPressed: () => Leader.fluentNav(
          context,
          Icon(FluentIcons.account_browser),
          Text("关注的用户"),
          UsersPage(
            id: int.parse(accountStore.now!.userId),
          ),
        ),
      ),
      tabs: [
        _buildTag(
          text: Text(I18n.of(context).news),
          icon: Icon(FluentIcons.dynamic_list),
        ),
        _buildTag(
          text: Text(I18n.of(context).bookmark),
          icon: Icon(FluentIcons.heart),
        ),
        _buildTag(
          text: Text(I18n.of(context).followed),
          icon: Icon(FluentIcons.user_followed),
        ),
      ],
      bodies: [
        NewIllustPage(),
        BookmarkPage(
          isNested: false,
          id: int.parse(accountStore.now!.userId),
        ),
        FollowList(
          id: int.parse(accountStore.now!.userId),
        ),
      ],
    );
  }

  Widget _buildContentWithoutSignin(BuildContext context) {
    final tabs = [
      _buildTag(
        text: Text('${I18n.of(context).follow}${I18n.of(context).news}'),
      ),
      _buildTag(
        text: Text('${I18n.of(context).personal}${I18n.of(context).bookmark}'),
      ),
      _buildTag(
        text: Text('${I18n.of(context).follow}${I18n.of(context).painter}'),
      ),
    ];
    return TabView(
      onChanged: (i) => setState(() => _currentIndex = i),
      currentIndex: _currentIndex,
      tabs: tabs,
      bodies: [
        LoginInFirst(),
        LoginInFirst(),
        LoginInFirst(),
      ],
    );
  }

  Tab _buildTag({required Widget text, Widget? icon}) {
    return Tab(text: text, icon: icon, closeIcon: null);
  }
}
