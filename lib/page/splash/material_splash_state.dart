import 'package:flutter/material.dart';
import 'package:pixez/main.dart';
import 'package:pixez/page/splash/common_splash_state.dart';

class MaterialSplashPageState extends SplashPageStateBase {
  @override
  Widget build(BuildContext context) {
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
  }
}
