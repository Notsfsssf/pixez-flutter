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
import 'package:pixez/page/hello/new/new_page.dart';
import 'package:pixez/page/hello/recom/recom_page.dart';
import 'package:pixez/page/hello/setting/setting_page.dart';
import 'package:pixez/page/picture/picture_page.dart';
import 'package:pixez/page/preview/preview_page.dart';
import 'package:pixez/page/search/search_page.dart';
import 'package:pixez/page/user/users_page.dart';
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
    _pageController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _pageController = PageController();
    super.initState();
    saveStore.saveStream.listen((stream) {
      listenBehavior(context, stream);
    });
    initPlatformState();
  }

  init() async {

  
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
      // Parse the link and warn the user, if it is not correct,
      // but keep in mind it could be `null`.
    } catch (e) {
      print(e);
      // Handle exception by warning the user their action did not succeed
      // return?
    }
  }

  int _selectedIndex = 0;
  PageController _pageController;
  List<Widget> _widgetOptions = <Widget>[
    ReComPage(),
    NewPage(),
    Observer(builder: (context) {
      if (accountStore.now != null) return SearchPage();
      return Scaffold(
        appBar: AppBar(
          title: Text(I18n.of(context).Search),
          actions: <Widget>[Icon(Icons.search)],
        ),
        body: LoginInFirst(),
      );
    }),
    SettingPage()
  ];

  var tapTime = [0, 0, 0, 0];
  var routes = ['recom', 'new', 'search', 'setting'];

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          var spaceTime =
              DateTime.now().millisecondsSinceEpoch - tapTime[index];
          print("${spaceTime}/${tapTime[index]}");
          if (spaceTime > 2000) {
            tapTime[index] = DateTime.now().millisecondsSinceEpoch;
          } else {

          }
          setState(() {
            _selectedIndex = index;
          });
        },
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.home),
              title: Text(I18n.of(context).Home)),
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.profile_circled),
              title: Text(I18n.of(context).My)),
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.search),
              title: Text(I18n.of(context).Search)),
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.settings),
              title: Text(I18n.of(context).Setting)),
        ],
      ),
      tabBuilder: (BuildContext context, int index) {
        return CupertinoTabView(
          builder: (context) {
            return _widgetOptions[index];
          },
        );
      },
    );
  }

  Drawer buildDrawer() => Drawer(
          child: Container(
        color: Colors.white,
        child: ListView(
          children: <Widget>[
            DrawerHeader(
              child: Align(
                alignment: Alignment.bottomRight,
                child: Image.asset('assets/images/mahou_teriri.jpg'),
              ),
            ),

            ListTile(
              title: Text('About'),
              subtitle: Text('来一起写flutter不啦'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            Divider(),
            ListTile(
              title: Text('Creator'),
              subtitle: Text('Perol_Notsfsssf'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Alpha-version'),
              subtitle: Text('No.525300887039'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Feedback E-mail'),
              subtitle: Text('PxEzFeedBack@outlook.com'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Made with'),
              subtitle: Text('Flutter'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Notice'),
              subtitle: Text('封测版(迫真)'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            //  ListTile(leading: Image.asset('asset/images/mahou_teriri.jpg'),),
          ],
        ),
      ));

  BottomNavigationBar _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          title: Text('Home'),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.assessment),
          title: Text('Ranking'),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_view_day),
          title: Text('New'),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          title: Text('Search'),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_circle),
          title: Text('My'),
        ),
      ],
      currentIndex: _selectedIndex,
      unselectedItemColor: Colors.grey,
      selectedItemColor: Theme.of(context).primaryColor,
      onTap: _onItemTapped,
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
