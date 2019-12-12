import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pixez/bloc/bloc.dart';
import 'package:pixez/page/hello/hello_page.dart';
import 'package:pixez/page/login/login_page.dart';
import 'package:pixez/page/search/search_page.dart';

import 'generated/i18n.dart';

 main(){
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final i18n = I18n.delegate;
    return BlocProvider(
      create: (context) => RouteBloc()..add(FetchDataBaseEvent()),
      child: MaterialApp(
        routes: {
          '/login': (context) => LoginPage(),
          '/': (context) => HelloPage(),
          '/search': (context) => SearchPage(),
        },
        initialRoute: '/',
        title: 'Flutter Demo',
        localeResolutionCallback:
            i18n.resolution(fallback: new Locale("en", "US")),
        localizationsDelegates: [
          i18n,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate
        ],
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
      ),
    );
  }
}
