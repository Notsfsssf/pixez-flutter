import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixez/bloc/account_bloc.dart';
import 'package:pixez/bloc/account_state.dart';
import 'package:pixez/bloc/bloc.dart';
import 'package:pixez/generated/i18n.dart';
import 'package:pixez/page/hello/new/new_page.dart';
import 'package:pixez/page/hello/recom/recom_page.dart';
import 'package:pixez/page/hello/setting/setting_page.dart';
import 'package:pixez/page/novel/novel_page.dart';
import 'package:pixez/page/preview/preview_page.dart';
import 'package:pixez/page/search/search_page.dart';

class HelloPage extends StatefulWidget {
  @override
  _HelloPageState createState() => _HelloPageState();
}

class _HelloPageState extends State<HelloPage> {
  int _selectedIndex = 0;
  PageController _pageController;
  List<Widget> _widgetOptions = <Widget>[
    ReComPage(),
    NewPage(),
    BlocBuilder<AccountBloc, AccountState>(builder: (context, snapshot) {
      if (snapshot is HasUserState) return SearchPage();
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
  var tapTime = [0, 0, 0, 0];
var   routes = ['recom', 'my', 'search', 'setting'];
  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          var spaceTime =DateTime.now().millisecondsSinceEpoch - tapTime[index];
          if (spaceTime > 2000) {
            print("${spaceTime}/${tapTime[index]}");
            BlocProvider.of<ControllerBloc>(context)
                .add(ScrollToTopEvent(routes[index]));
            tapTime[index]=DateTime.now().millisecondsSinceEpoch;
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
}
