import 'package:flutter/widgets.dart';
import 'package:pixez/src/generated/i18n/app_localizations.dart';

class I18n {
  static List<Locale> supportedLocales = AppLocalizations.supportedLocales;

  static AppLocalizations of(BuildContext context) {
    return AppLocalizations.of(context)!;
  }

  static AppLocalizations ofContext() {
    return AppLocalizations.of(context!)!;
  }

  static BuildContext? context;
}
