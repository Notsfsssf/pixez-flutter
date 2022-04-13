import 'package:bot_toast/bot_toast.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:pixez/main.dart';
import 'package:pixez/page/splash/fluent_splash_page.dart';

class MyFluentApp extends StatefulWidget {
  late Color _accentColor;
  late bool _isDarkTheme;

  MyFluentApp(Color accentColor, bool isDarkTheme) {
    _accentColor = accentColor;
    _isDarkTheme = isDarkTheme;
  }

  @override
  _MyFluentAppState createState() =>
      _MyFluentAppState(_accentColor, _isDarkTheme);
}

class _MyFluentAppState extends State<MyFluentApp> with WidgetsBindingObserver {
  late Color _accentColor;
  late bool _isDarkTheme;

  _MyFluentAppState(Color accentColor, bool isDarkTheme) {
    _accentColor = accentColor;
    _isDarkTheme = isDarkTheme;
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      final botToastBuilder = BotToastInit();
      return FluentApp(
        navigatorObservers: [BotToastNavigatorObserver(), routeObserver],
        locale: userSetting.locale,
        home: Builder(builder: (context) {
          return AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle(statusBarColor: Colors.transparent),
              child: FluentSplashPage());
        }),
        title: 'PixEz',
        builder: (context, child) {
          child = botToastBuilder(context, child);
          return Directionality(
            textDirection: TextDirection.ltr,
            child: NavigationPaneTheme(
              data:
                  NavigationPaneThemeData(backgroundColor: Colors.transparent),
              child: child,
            ),
          );
        },
        themeMode: userSetting.themeMode,
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          visualDensity: VisualDensity.standard,
          accentColor: _accentColor.toAccentColor(),
          focusTheme: FocusThemeData(
            glowFactor: is10footScreen() ? 2.0 : 0.0,
          ),
        ),
        theme: ThemeData(
          visualDensity: VisualDensity.standard,
          accentColor: _accentColor.toAccentColor(),
          focusTheme: FocusThemeData(
            glowFactor: is10footScreen() ? 2.0 : 0.0,
          ),
        ),
        localizationsDelegates: [
          _FluentLocalizationsDelegate(),
          ...AppLocalizations.localizationsDelegates
        ],
        supportedLocales: AppLocalizations.supportedLocales, // Add this line
      );
    });
  }
}

class _FluentLocalizationsDelegate
    extends LocalizationsDelegate<FluentLocalizations> {
  const _FluentLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales.contains(locale);
  }

  @override
  Future<FluentLocalizations> load(Locale locale) {
    return DefaultFluentLocalizations.load(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<FluentLocalizations> old) {
    return false;
  }
}
