import 'package:flutter/widgets.dart';
import 'package:mobx/mobx.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/lighting/lighting_store.dart';
import 'package:pixez/main.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/network/oauth_client.dart';
import 'package:pixez/page/splash/common_splash_page.dart';

abstract class SplashPageStateBase extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  LightingStore? lightingStore;

  @override
  void initState() {
    if (accountStore.now != null)
      lightingStore = LightingStore(
          ApiSource(futureGet: () => apiClient.getRecommend()), null);
    controller =
        AnimationController(duration: Duration(seconds: 2), vsync: this);
    initMethod();
    super.initState();
    controller.forward();
  }

  late ReactionDisposer reactionDisposer, userDisposer;

  bool isPush = false;

  initMethod() {
    userDisposer = reaction((_) => userSetting.disableBypassSni, (_) {
      if (userSetting.disableBypassSni) {
        apiClient.httpClient.options.baseUrl =
            'https://${ApiClient.BASE_API_URL_HOST}';
        oAuthClient.httpClient.options.baseUrl =
            'https://${OAuthClient.BASE_OAUTH_URL_HOST}';
        Leader.pushUntilHome(context);
        isPush = true;
      }
    });
    reactionDisposer = reaction((_) => splashStore.helloWord, (_) {
      if (mounted && !isPush) {
        Leader.pushUntilHome(context);
        isPush = true;
      }
    });
    splashStore.hello();
  }

  @override
  void dispose() {
    controller.dispose();
    userDisposer();
    reactionDisposer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context);
}
