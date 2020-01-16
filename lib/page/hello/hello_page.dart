import 'package:bot_toast/bot_toast.dart';
import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pixez/bloc/save_bloc.dart';
import 'package:pixez/bloc/save_state.dart';
import 'package:pixez/generated/i18n.dart';
import 'package:pixez/models/account.dart';
import 'package:pixez/page/hello/new/new_page.dart';
import 'package:pixez/page/hello/ranking/ranking_page.dart';
import 'package:pixez/page/hello/recom/recom_page.dart';
import 'package:pixez/page/hello/setting/setting_page.dart';
import 'package:pixez/page/history/history_page.dart';
import 'package:pixez/page/login/login_page.dart';
import 'package:pixez/page/search/search_page.dart';
import 'package:url_launcher/url_launcher.dart';

class HelloPage extends StatefulWidget {
  @override
  _HelloPageState createState() => _HelloPageState();
}

class _HelloPageState extends State<HelloPage> {
  int _selectedIndex = 0;
  PageController _pageController;
  List<Widget> _widgetOptions = <Widget>[
    ReComPage(),
    RankingPage(),
    NewPage(),
    SearchPage(),
    SettingPage()
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SaveBloc, SaveState>(
      child: CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
                icon: Icon(Icons.home), title: Text(I18n.of(context).Home)),
            BottomNavigationBarItem(
                icon: Icon(Icons.assessment),
                title: Text(I18n.of(context).Rank)),
            BottomNavigationBarItem(
                icon: Icon(Icons.calendar_view_day),
                title: Text(I18n.of(context).Quick_View)),
            BottomNavigationBarItem(
                icon: Icon(Icons.search), title: Text(I18n.of(context).Search)),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings),
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
      ),
      listener: (BuildContext context, SaveState state) {
        if(state is SaveSuccesState)
        BotToast.showNotification(
            leading: (_) => Icon(Icons.stay_current_landscape),
            title: (_) => Text(I18n.of(context).Save));
            if(state is SaveAlreadyGoingOnState)
             BotToast.showNotification(
            leading: (_) => Icon(Icons.stay_current_landscape),
            title: (_) => Text("OK")); 
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

  /*Widget _buildBottomNavy() => BottomNavyBar(
        selectedIndex: _selectedIndex,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        showElevation: false, // use this to remove appBar's elevation
        onItemSelected: (index) => setState(() {
          _selectedIndex = index;
          _pageController.animateToPage(index,
              duration: Duration(milliseconds: 300), curve: Curves.ease);
        }),
        items: [
          BottomNavyBarItem(
            icon: Icon(Icons.home),
            title: Text(I18n.of(context).Home),
            activeColor: Colors.red,
          ),
          BottomNavyBarItem(
              icon: Icon(Icons.assessment),
              title: Text(I18n.of(context).Rank),
              activeColor: Colors.purpleAccent),
          BottomNavyBarItem(
              icon: Icon(Icons.calendar_view_day),
              title: Text(I18n.of(context).Quick_View),
              activeColor: Colors.pink),
          BottomNavyBarItem(
              icon: Icon(Icons.search),
              title: Text(I18n.of(context).Search),
              activeColor: Colors.blue),
          BottomNavyBarItem(
              icon: Icon(Icons.history),
              title: Text(I18n.of(context).History),
              activeColor: Colors.amber),
        ],
      );*/

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

  Future findUser() async {
    PermissionStatus permission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.storage);
    bool isShown = await PermissionHandler()
        .shouldShowRequestPermissionRationale(PermissionGroup.storage);
    AccountProvider accountProvider = new AccountProvider();
    await accountProvider.open();
    List list = await accountProvider.getAllAccount();
    if (list.length <= 0) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (BuildContext context) {
        return LoginPage();
      }));
    }
  }
}
