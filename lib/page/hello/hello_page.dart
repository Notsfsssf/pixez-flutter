import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pixez/models/account.dart';
import 'package:pixez/page/hello/bloc/bloc.dart';
import 'package:pixez/page/hello/recom/recom_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HelloPage extends StatefulWidget {
  @override
  _HelloPageState createState() => _HelloPageState();
}

class _HelloPageState extends State<HelloPage> {
  int _selectedIndex = 0;

  @override
  initState() {
    super.initState();
  }

  List<Widget> _widgetOptions = <Widget>[
    ReComPage(),
    Text(
      'Index 1: Business',
    ),
    Text(
      'Index 2: School',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      builder: (context) => HelloBloc()..add(FetchDataBaseEvent()),
      child: BlocListener<HelloBloc, HelloState>(
        listener: (_, state) {
          if (state is NoneUserState) {
            Navigator.pushNamed(context, '/login');
          }
        },
        child: BlocBuilder<HelloBloc, HelloState>(
          builder: (BuildContext context1, state) {
            if (state is HasUserState)
              return Scaffold(
                appBar: AppBar(
                  leading: Icon(Icons.menu),
                  centerTitle: true,
                  title: Text("data"),
                  actions: <Widget>[
                    IconButton(
                      icon: Icon(Icons.search),
                      onPressed: () => {},
                    )
                  ],
                ),
                body: Center(
                  child: _widgetOptions.elementAt(_selectedIndex),
                ),
                bottomNavigationBar: BottomNavigationBar(
                  items: const <BottomNavigationBarItem>[
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home),
                      title: Text('Home'),
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.business),
                      title: Text('Business'),
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.school),
                      title: Text('School'),
                    ),
                  ],
                  currentIndex: _selectedIndex,
                  selectedItemColor: Colors.amber[800],
                  onTap: _onItemTapped,
                ),
              );
            else if (state is NoneUserState) {}
            return Container();
          },
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future findUser() async {
    AccountProvider accountProvider = new AccountProvider();
    await accountProvider.open();
    List list = await accountProvider.getAllAccount();
    if (list.length <= 0) {
      Navigator.of(context).pushNamed('/login');
    }
  }
}
