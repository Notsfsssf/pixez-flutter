import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pixez/bloc/bloc.dart';
import 'package:pixez/page/hello/hello_page.dart';
import 'package:pixez/page/history/history_page.dart';
import 'package:pixez/page/login/login_page.dart';
import 'package:pixez/page/search/bloc/bloc.dart';
import 'package:pixez/page/search/search_page.dart';
import 'package:pixez/page/splash/splash_page.dart';

import 'generated/i18n.dart';
class SimpleBlocDelegate extends BlocDelegate {
  @override
  void onEvent(Bloc bloc, Object event) {
    super.onEvent(bloc, event);
    print(event);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print(transition);
  }

  @override
  void onError(Bloc bloc, Object error, StackTrace stacktrace) {
    super.onError(bloc, error, stacktrace);
    print(error);
  }
}
main() {
  BlocSupervisor.delegate = SimpleBlocDelegate();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final i18n = I18n.delegate;
    return MultiBlocProvider(
      providers: [
        BlocProvider<RouteBloc>(
          create: (context) => RouteBloc(),
        ),
        BlocProvider<AccountBloc>(
          create: (context) => AccountBloc()..add(FetchDataBaseEvent()),
        ),
        BlocProvider<TagHistoryBloc>(
          create: (BuildContext context) => TagHistoryBloc(),
        ),
        BlocProvider<SaveBloc>(
          create: (context) => SaveBloc(),
        ),
        BlocProvider(
          create: (context) => HistoryPersistBloc(),
        )
      ],
      child: MaterialApp(
        darkTheme: ThemeData(
            primaryColor: Colors.white
        ),
        routes: {
          '/login': (context) => LoginPage(),
          '/hello': (context) => HelloPage(),
          '/search': (context) => SearchPage(),
          '/': (context) => SplashPage(),
          '/history':(context)=>HistoryPage(),
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