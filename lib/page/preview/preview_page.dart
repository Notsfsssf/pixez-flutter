import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/generated/i18n.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/login/login_page.dart';
import 'package:pixez/page/preview/bloc.dart';

class PreviewPage extends StatelessWidget {
  List<Widget> _widgetOptions = <Widget>[
    PreviewSplash(),
    LoginInFirst(),
    LoginInFirst(),
    LoginInFirst(),
    LoginInFirst(),
  ];
  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.home),
              title: Text(I18n.of(context).Home)),
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.shuffle),
              title: Text(I18n.of(context).Rank)),
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.eye),
              title: Text(I18n.of(context).Quick_View)),
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
}

class GoToLoginPage extends StatelessWidget {
  final String url;

  const GoToLoginPage(
    this.url, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            PixivImage(url),

          ],
        ),
      ),
    );
  }
}

class LoginInFirst extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(child: Text('>_<',style: TextStyle(fontSize: 26),),),
          Center(child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(I18n.of(context).Login_message),
          )),
          RaisedButton(
            child: Text(I18n.of(context).Go_to_Login),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) {
                return LoginPage();
              }));
            },
          )
        ],
      ),
    );
  }
}

class PreviewSplash extends StatefulWidget {
  @override
  _PreviewSplashState createState() => _PreviewSplashState();
}

class _PreviewSplashState extends State<PreviewSplash> {
  EasyRefreshController _easyRefreshController = EasyRefreshController();
  Completer<void> _refreshCompleter = Completer(), _loadCompleter = Completer();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Walkthrough!'),
      ),
      body: BlocProvider<WalkThroughBloc>(
        child: BlocListener<WalkThroughBloc, WalkThroughState>(
          child: BlocBuilder<WalkThroughBloc, WalkThroughState>(
              builder: (context, state) {
            return EasyRefresh(
              onLoad: () async {
                if (state is DataWalkThroughState) {
                  BlocProvider.of<WalkThroughBloc>(context)
                      .add(LoadMoreWalkThroughEvent(
                    state.nextUrl,
                    state.illusts,
                  ));
                  return _loadCompleter.future;
                }
                return;
              },
              controller: _easyRefreshController,
              child: (state is DataWalkThroughState)
                  ? StaggeredGridView.countBuilder(
                      crossAxisCount: 2,
                      itemBuilder: (BuildContext context, int index) {
                        return InkWell(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    GoToLoginPage(state
                                        .illusts[index].imageUrls.medium)));
                          },
                          child: Card(
                            child: Container(
                              child: PixivImage(
                                  state.illusts[index].imageUrls.squareMedium),
                            ),
                          ),
                        );
                      },
                      itemCount: state.illusts.length,
                      staggeredTileBuilder: (int index) => StaggeredTile.fit(1),
                    )
                  : Container(),
            );
          }),
          listener: (BuildContext context, WalkThroughState state) {
            if (state is DataWalkThroughState) {
              _loadCompleter?.complete();
              _loadCompleter = Completer();
              _refreshCompleter?.complete();
              _refreshCompleter = Completer();
            }
          },
        ),
        create: (context) =>
            WalkThroughBloc(RepositoryProvider.of<ApiClient>(context))
              ..add(FetchWalkThroughEvent()),
      ),
    );
  }
}
