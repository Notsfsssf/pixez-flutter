import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:pixez/generated/l10n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/network/oauth_client.dart';
import 'package:pixez/network/onezero_client.dart';
import 'package:pixez/page/hello/android_hello_page.dart';
import 'package:pixez/page/hello/hello_page.dart';
import 'package:pixez/page/splash/splash_store.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  SplashStore splashStore;
  @override
  void initState() {
    splashStore = SplashStore(OnezeroClient())..fetch();
    controller =
        AnimationController(duration: Duration(seconds: 2), vsync: this);
    initMethod();
    super.initState();
    controller.forward();
  }

  ReactionDisposer reactionDisposer;
  initMethod() {
    reactionDisposer = reaction((_) => splashStore.helloWord, (_) {
      try {
        if (splashStore.onezeroResponse != null) {
          var address = splashStore.onezeroResponse.answer.first.data;
          print('address:$address');
          if (address != null && address.isNotEmpty) {
            RepositoryProvider.of<ApiClient>(context)
                .httpClient
                .options
                .baseUrl = 'https://$address';
            RepositoryProvider.of<OAuthClient>(context)
                .httpClient
                .options
                .baseUrl = 'https://$address';
          }
        }
      } catch (e) {
        print(e);
      }
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) =>
                  Platform.isIOS ? HelloPage() : AndroidHelloPage()));
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    reactionDisposer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    saveStore.initContext(I18n.of(context));
    return Observer(builder: (_) {
      return Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            RotationTransition(
                child: Image.asset(
                  'assets/images/icon.png',
                  height: 80,
                  width: 80,
                ),
                alignment: Alignment.center,
                turns: controller),
            Container(
              child: Text(
                splashStore.helloWord,
                textAlign: TextAlign.center,
              ),
            )
          ],
        ),
      );
    });
  }
}
