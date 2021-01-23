import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/material.dart' hide NestedScrollView;
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/generated/l10n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/illust.dart';
import 'package:pixez/page/shield/shield_page.dart';
import 'package:pixez/page/user/bookmark/bookmark_page.dart';
import 'package:pixez/page/user/detail/user_detail.dart';
import 'package:pixez/page/user/user_store.dart';
import 'package:pixez/page/user/works/works_page.dart';

class UserPage extends StatefulWidget {
  final int id;
  final User user;

  const UserPage({Key key, @required this.id, this.user}) : super(key: key);

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage>
    with SingleTickerProviderStateMixin {
  UserStore userStore;
  TabController _tabController;
  ScrollController _scrollController;
  int _tabIndex = 0;

  @override
  void initState() {
    userStore = UserStore(widget.id, user: widget.user);
    _tabController = TabController(length: 3, vsync: this);
    _scrollController = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      if (muteStore.banUserIds.isNotEmpty) {
        if (muteStore.banUserIds
            .map((element) => int.parse(element.userId))
            .contains(widget.id)) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0.0,
            ),
            extendBodyBehindAppBar: true,
            extendBody: true,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('X_X'),
                  RaisedButton(
                    child: Text(I18n.of(context).shielding_settings),
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) => ShieldPage()));
                    },
                  )
                ],
              ),
            ),
          );
        }
      }

      if (userStore.errorMessage != null) {
        if (userStore.errorMessage == '404')
          return Scaffold(
            appBar: AppBar(),
            body: Container(
                child: Center(
              child: Text('404 not found'),
            )),
          );
        return Scaffold(
          appBar: AppBar(),
          body: Container(
              child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Http error'),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: RaisedButton(
                    color: Theme.of(context).accentColor,
                    onPressed: () {
                      userStore.errorMessage = null;
                      userStore.firstFetch();
                    },
                    child: Text(I18n.of(context).refresh),
                  ),
                )
              ],
            ),
          )),
        );
      }
      return Scaffold(
          body: NestedScrollView(
        pinnedHeaderSliverHeightBuilder: () {
          return MediaQuery.of(context).padding.top + kToolbarHeight + 46.0;
        },
        controller: _scrollController,
        innerScrollPositionKeyBuilder: () {
          var index = "Tab";
          index += _tabController.index.toString();
          return Key(index);
        },
            body: IndexedStack(index: _tabIndex, children: [
              NestedScrollViewInnerScrollPositionKeyWidget(
                  Key('Tab0'),
                  WorksPage(
                    id: widget.id,
                  )),
              NestedScrollViewInnerScrollPositionKeyWidget(
                  Key('Tab1'),
                  BookmarkPage(
                    isNested: true,
                    id: widget.id,
                  )),
              NestedScrollViewInnerScrollPositionKeyWidget(
                  Key('Tab2'), UserDetailPage(userDetail: userStore.userDetail)),
            ]),
      ));
    });
  }
}
