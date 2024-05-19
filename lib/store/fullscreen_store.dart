import 'package:mobx/mobx.dart';
import 'package:pixez/models/account.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'fullscreen_store.g.dart';

class FullScreenStore = _FullScreenStoreBase with _$FullScreenStore;

abstract class _FullScreenStoreBase with Store {
  @observable
  bool fullscreen = false;

  @action
  void toggle() {
    fullscreen = !fullscreen;
  }
}
