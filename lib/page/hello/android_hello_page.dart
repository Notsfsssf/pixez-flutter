import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pixez/bloc/account_bloc.dart';
import 'package:pixez/bloc/account_event.dart';
import 'package:pixez/bloc/account_state.dart';
import 'package:pixez/component/painter_avatar.dart';
import 'package:pixez/generated/l10n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/page/Init/init_page.dart';
import 'package:pixez/page/about/about_page.dart';
import 'package:pixez/page/account/edit/account_edit_page.dart';
import 'package:pixez/page/account/select/account_select_page.dart';
import 'package:pixez/page/hello/new/new_page.dart';
import 'package:pixez/page/hello/ranking/rank_page.dart';
import 'package:pixez/page/hello/recom/recom_spotlight_page.dart';
import 'package:pixez/page/hello/setting/setting_page.dart';
import 'package:pixez/page/hello/setting/setting_quality_page.dart';
import 'package:pixez/page/history/history_page.dart';
import 'package:pixez/page/login/login_page.dart';
import 'package:pixez/page/picture/picture_page.dart';
import 'package:pixez/page/platform/platform_page.dart';
import 'package:pixez/page/preview/preview_page.dart';
import 'package:pixez/page/progress/progress_page.dart';
import 'package:pixez/page/search/search_page.dart';
import 'package:pixez/page/shield/shield_page.dart';
import 'package:pixez/page/user/users_page.dart';
import 'package:pixez/store/save_store.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_links/uni_links.dart';

class AndroidHelloPage extends StatefulWidget {
  @override
  _AndroidHelloPageState createState() => _AndroidHelloPageState();
}

class _AndroidHelloPageState extends State<AndroidHelloPage> {
  List<Widget> _widgetOptions = <Widget>[
    RecomSpolightPage(),
    RankPage(),
    NewPage(),
    SearchPage(),
    SettingPage()
  ];
  int index = 0;

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      if (accountStore.now != null)
        return Scaffold(
          body: IndexedStack(
            index: index,
            children: _widgetOptions,
          ),
          bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: index,
              onTap: (index) {
                setState(() {
                  this.index = index;
                });
              },
              items: [
                BottomNavigationBarItem(
                    icon: Icon(Icons.home), title: Text(I18n.of(context).Home)),
                BottomNavigationBarItem(
                    icon: Icon(Icons.ac_unit),
                    title: Text(I18n.of(context).Rank)),
                BottomNavigationBarItem(
                    icon: Icon(Icons.bookmark),
                    title: Text(I18n.of(context).Quick_View)),
                BottomNavigationBarItem(
                    icon: Icon(Icons.search),
                    title: Text(I18n.of(context).Search)),
                BottomNavigationBarItem(
                    icon: Icon(Icons.settings),
                    title: Text(I18n.of(context).Setting)),
              ]),
        );
      return LoginPage();
    });
  }

  @override
  void initState() {
    super.initState();
    saveStore.saveStream.listen((stream) {
      listenBehavior(context, stream);
    });
    initPlatformState();
  }

  judgePushPage(Uri link) {
    if (link.path.contains("artworks")) {
      List<String> paths = link.pathSegments;
      int index = paths.indexOf("artworks");
      if (index != -1) {
        try {
          int id = int.parse(paths[index + 1]);
          Navigator.of(context, rootNavigator: true)
              .push(MaterialPageRoute(builder: (context) {
            return PicturePage(null, id);
          }));
          return;
        } catch (e) {}
      }
    }
    if (link.path.contains("users")) {
      List<String> paths = link.pathSegments;
      int index = paths.indexOf("users");
      if (index != -1) {
        try {
          int id = int.parse(paths[index + 1]);
          Navigator.of(context, rootNavigator: true)
              .push(MaterialPageRoute(builder: (context) {
            return UsersPage(
              id: id,
            );
          }));
        } catch (e) {
          print(e);
        }
      }
    }
    if (link.queryParameters['illust_id'] != null) {
      try {
        var id = link.queryParameters['illust_id'];
        Navigator.of(context, rootNavigator: true)
            .push(MaterialPageRoute(builder: (context) {
          return PicturePage(null, int.parse(id));
        }));

        return;
      } catch (e) {}
    }
    if (link.queryParameters['id'] != null) {
      try {
        var id = link.queryParameters['id'];
        Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
            builder: (context) => UsersPage(
                  id: int.parse(id),
                )));

        return;
      } catch (e) {}
    }
    if (link.pathSegments.length >= 2) {
      String i = link.pathSegments[link.pathSegments.length - 2];
      if (i == "i") {
        try {
          int id = int.parse(link.pathSegments[link.pathSegments.length - 1]);
          Navigator.of(context, rootNavigator: true)
              .push(MaterialPageRoute(builder: (context) {
            return PicturePage(null, id);
          }));
          return;
        } catch (e) {}
      }

      if (i == "u") {
        try {
          int id = int.parse(link.pathSegments[link.pathSegments.length - 1]);
          Navigator.of(context, rootNavigator: true)
              .push(MaterialPageRoute(builder: (context) {
            return UsersPage(
              id: id,
            );
          }));
          return;
        } catch (e) {}
      }
    }
  }

  StreamSubscription _sub;

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  initPlatformState() async {
    try {
      Uri initialLink = await getInitialUri();
      print(initialLink);
      if (initialLink != null) judgePushPage(initialLink);
      _sub = getUriLinksStream().listen((Uri link) {
        print("link:${link}");
        judgePushPage(link);
      });
      // Parse the link and warn the user, if it is not correct,
      // but keep in mind it could be `null`.
    } catch (e) {
      print(e);
      // Handle exception by warning the user their action did not succeed
      // return?
    }
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
    ].request();
    var prefs = await SharedPreferences.getInstance();
    if (prefs.getInt('language_num') == null) {
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (context) => InitPage()));
    }
  }

}
