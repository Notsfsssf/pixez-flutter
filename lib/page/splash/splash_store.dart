import 'package:mobx/mobx.dart';
import 'package:pixez/models/onezero_response.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/network/onezero_client.dart';
part 'splash_store.g.dart';

class SplashStore = _SplashStoreBase with _$SplashStore;

abstract class _SplashStoreBase with Store {
  final OnezeroClient onezeroClient;
  @observable
  String helloWord = "= w =";
  @observable
  OnezeroResponse onezeroResponse;
  _SplashStoreBase(this.onezeroClient);
  @action
  fetch() async {
    try {
      OnezeroResponse onezeroResponse =
          await onezeroClient.queryDns(ApiClient.BASE_API_URL_HOST);
      this.onezeroResponse = onezeroResponse;
   helloWord = '♪^∀^●)ノ';
    } catch (e) {
      print(e);
   helloWord = 'T_T';
    }
  }
}
