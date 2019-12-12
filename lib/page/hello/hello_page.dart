import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pixez/bloc/bloc.dart';
import 'package:pixez/models/account.dart';
import 'package:pixez/page/hello/bloc/bloc.dart';
import 'package:pixez/page/hello/new/new_page.dart';
import 'package:pixez/page/hello/ranking/ranking_page.dart';
import 'package:pixez/page/hello/recom/recom_page.dart';
import 'package:pixez/page/my/my_page.dart';
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
    RankingPage(),
    NewPage(),
    SearchPage(),
    MyPage()
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
    return BlocProvider(
      create: (context) => HelloBloc(),
      child: BlocListener<HelloBloc, HelloState>(
        listener: (_, state) {
          if (state is NoneUserState) {
            Navigator.pushReplacementNamed(context, '/login');
          }
        },
        child: BlocBuilder<RouteBloc, RouteState>(
          builder: (BuildContext context1, state) {
            if (state is HasUserState)
              return Scaffold(
                body: SizedBox.expand(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() => _selectedIndex = index);
                    },
                    children: _widgetOptions,
                  ),
                ),
                bottomNavigationBar: _buildBottomNavy(),
              );
            else if (state is NoneUserState) {}
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBottomNavy() => BottomNavyBar(
        selectedIndex: _selectedIndex,
        showElevation: true, // use this to remove appBar's elevation
        onItemSelected: (index) => setState(() {
          _selectedIndex = index;
          _pageController.animateToPage(index,
              duration: Duration(milliseconds: 300), curve: Curves.ease);
        }),
        items: [
          BottomNavyBarItem(
            icon: Icon(Icons.home),
            title: Text('Home'),
            activeColor: Colors.red,
          ),
          BottomNavyBarItem(
              icon: Icon(Icons.assessment),
              title: Text('Ranking'),
              activeColor: Colors.purpleAccent),
          BottomNavyBarItem(
              icon: Icon(Icons.calendar_view_day),
              title: Text('New'),
              activeColor: Colors.pink),
          BottomNavyBarItem(
              icon: Icon(Icons.search),
              title: Text('Search'),
              activeColor: Colors.blue),
          BottomNavyBarItem(
              icon: Icon(Icons.settings),
              title: Text('Settings'),
              activeColor: Colors.amber),
        ],
      );

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
      Navigator.of(context).pushNamed('/login');
    }
  }
}
