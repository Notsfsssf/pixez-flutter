import 'package:bot_toast/bot_toast.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/constants.dart';
import 'package:pixez/fluent/page/splash/splash_page.dart';
import 'package:pixez/fluent/platform/platform.dart';
import 'package:pixez/main.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:window_manager/window_manager.dart';

Color? _fluentuiBgColor = null;

initFluent(List<String> args) async {
  if (!Constants.isFluent) return;

  final dbPath = await getDBPath();
  if (dbPath != null) databaseFactory.setDatabasesPath(dbPath);

  // Must add this line.
  await windowManager.ensureInitialized();
  await windowManager.waitUntilReadyToShow(
    WindowOptions(
      titleBarStyle: TitleBarStyle.hidden,
      center: true,
      skipTaskbar: false,
      minimumSize: const Size(350, 600),
    ),
    () async {
      await Window.initialize();

      await windowManager.show();
      await windowManager.focus();
    },
  );
}

Future _applyEffect(bool isDark) async {
  if (!Constants.isFluent) return;

  final effect = await getEffect();
  debugPrint("背景特效: $effect; 暗色主题: $isDark;");

  if (effect != WindowEffect.disabled)
    await windowManager.setBackgroundColor(
      _fluentuiBgColor = Colors.transparent,
    );

  await Window.setEffect(
    effect: effect,
    dark: isDark,
  );
}

Widget buildFluentUI(BuildContext context) {
  if (!Constants.isFluent) return Container();

  return DynamicColorBuilder(
    builder: (lightDynamic, darkDynamic) {
      return Observer(builder: (context) {
        final mode = userSetting.themeMode;
        final platformBrightness = MediaQuery.platformBrightnessOf(context);
        final isDark = mode == ThemeMode.dark ||
            (mode == ThemeMode.system && platformBrightness == Brightness.dark);

        _applyEffect(isDark);
        final botToastBuilder = BotToastInit();
        return FluentApp(
          home: Builder(builder: (context) {
            return AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle(statusBarColor: _fluentuiBgColor),
              child: SplashPage(),
            );
          }),
          builder: (context, child) {
            child = botToastBuilder(context, child);
            return Directionality(
              textDirection: TextDirection.ltr,
              child: NavigationPaneTheme(
                data: NavigationPaneThemeData(
                  backgroundColor: _fluentuiBgColor,
                ),
                child: child,
              ),
            );
          },
          title: 'PixEz',
          locale: userSetting.locale,
          navigatorObservers: [
            BotToastNavigatorObserver(),
            routeObserver,
          ],
          themeMode: userSetting.themeMode,
          darkTheme: FluentThemeData(
            brightness: Brightness.dark,
            visualDensity: VisualDensity.standard,
            accentColor: darkDynamic?.primary.toAccentColor(),
            focusTheme: FocusThemeData(
              glowFactor: is10footScreen(context) ? 2.0 : 0.0,
            ),
          ),
          theme: FluentThemeData(
            brightness: Brightness.light,
            visualDensity: VisualDensity.standard,
            accentColor: lightDynamic?.primary.toAccentColor(),
            focusTheme: FocusThemeData(
              glowFactor: is10footScreen(context) ? 2.0 : 0.0,
            ),
          ),
          localizationsDelegates: [
            _FluentLocalizationsDelegate(),
            ...AppLocalizations.localizationsDelegates
          ],
          supportedLocales: AppLocalizations.supportedLocales, // Add this line
        );
      });
    },
  );
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
    return FluentLocalizations.delegate.load(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<FluentLocalizations> old) {
    return false;
  }
}
