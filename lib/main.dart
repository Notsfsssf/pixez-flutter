import 'package:flutter/material.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pixez/page/hello/hello_page.dart';
import 'package:pixez/page/login/login_page.dart';
import 'generated/i18n.dart';
import 'models/account.dart';

Future main() async {

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final i18n = I18n.delegate;
    return MaterialApp(
      routes: {
        '/login': (context) => LoginPage(),
        '/': (context) => HelloPage()
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
    );
  }
}
