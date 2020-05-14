import 'package:bloc/bloc.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pixez/bloc/bloc.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/network/oauth_client.dart';
import 'package:pixez/page/search/bloc/bloc.dart';
import 'package:pixez/page/splash/splash_page.dart';
import 'package:pixez/store/save_store.dart';
import 'package:pixez/store/user_setting.dart';
import 'generated/i18n.dart';

final UserSetting userSetting = UserSetting();
final SaveStore saveStore = SaveStore();

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

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final i18n = I18n.delegate;
  @override
  void initState() {
    super.initState();
    I18n.onLocaleChanged = onLocaleChange;
    userSetting.init();
  }

  void onLocaleChange(Locale locale) {
    setState(() {
      I18n.locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    I18n.locale = i18n.supportedLocales[userSetting.languageNum];
    return MultiBlocProvider(
      providers: [
        BlocProvider<IapBloc>(
          create: (context) => IapBloc()..add(InitialEvent()),
        ),
        BlocProvider<RouteBloc>(
          create: (context) => RouteBloc(),
        ),
        BlocProvider<IllustPersistBloc>(
          create: (context) => IllustPersistBloc(),
        ),
        BlocProvider<AccountBloc>(
          create: (context) => AccountBloc()..add(FetchDataBaseEvent()),
        ),
        BlocProvider<TagHistoryBloc>(
          create: (BuildContext context) => TagHistoryBloc(),
        ),
        BlocProvider<MuteBloc>(
          create: (context) => MuteBloc()..add(FetchMuteEvent()),
        ),
        BlocProvider<ControllerBloc>(
          create: (context) => ControllerBloc(),
        )
      ],
      child: MultiRepositoryProvider(
        providers: [
          RepositoryProvider<ApiClient>(
            create: (BuildContext context) => ApiClient(),
          ),
          RepositoryProvider<OAuthClient>(
            create: (BuildContext context) => OAuthClient(),
          ),
        ],
        child: MaterialApp(
          navigatorObservers: [BotToastNavigatorObserver()],
          home: SplashPage(),
          title: 'PixEz',
          builder: BotToastInit(),
          theme: ThemeData(
            primarySwatch: Colors.lightBlue,
            brightness: Brightness.light,
          ),
          darkTheme: ThemeData(
              brightness: Brightness.dark, primarySwatch: Colors.orange),
          supportedLocales: i18n.supportedLocales,
          localeResolutionCallback: i18n.resolution(
              fallback: i18n.supportedLocales[userSetting.languageNum]),
          localizationsDelegates: [
            i18n,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate
          ],
        ),
      ),
    );
  }
}
