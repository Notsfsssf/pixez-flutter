import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/bloc/account_bloc.dart';
import 'package:pixez/bloc/account_state.dart';
import 'package:pixez/bloc/bloc.dart';
import 'package:pixez/generated/l10n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/page/Init/init_page.dart';
import 'package:pixez/page/hello/new/new_page.dart';
import 'package:pixez/page/hello/ranking/rank_page.dart';
import 'package:pixez/page/hello/recom/recom_page.dart';
import 'package:pixez/page/hello/recom/recom_spotlight_page.dart';
import 'package:pixez/page/hello/setting/setting_page.dart';
import 'package:pixez/page/login/login_page.dart';
import 'package:pixez/page/picture/picture_page.dart';
import 'package:pixez/page/preview/preview_page.dart';
import 'package:pixez/page/search/search_page.dart';
import 'package:pixez/page/user/users_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_links/uni_links.dart';
import 'package:pixez/store/save_store.dart';

class HelloPage extends StatefulWidget {
  @override
  _HelloPageState createState() => _HelloPageState();
}

class _HelloPageState extends State<HelloPage> {
  StreamSubscription _sub;
  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
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

  initPlatformState() async {
    try {
      Uri initialLink = await getInitialUri();
      print(initialLink);
      if (initialLink != null) judgePushPage(initialLink);
      _sub = getUriLinksStream().listen((Uri link) {
        print("link:${link}");
        judgePushPage(link);
      });
    } catch (e) {
      print(e);
    }
      var prefs = await SharedPreferences.getInstance();
       if (prefs.getInt('language_num') == null) {
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (context) => InitPage()));
    }
  }

  int index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Observer(builder: (_) {
        return IndexedStack(
          index: index,
          children: accountStore.now != null
              ? <Widget>[
                  RecomSpolightPage(),
                  NewPage(),
                  SearchPage(),
                  SettingPage()
                ]
              : [PreviewPage(), NewPage(), SearchPage(), SettingPage()],
        );
      }),
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
                icon: Icon(Icons.bookmark),
                title: Text(I18n.of(context).Quick_View)),
            BottomNavigationBarItem(
                icon: Icon(Icons.search), title: Text(I18n.of(context).Search)),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                title: Text(I18n.of(context).Setting)),
          ]),
    );
  }
}
