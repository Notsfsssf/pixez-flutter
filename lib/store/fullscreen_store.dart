import 'package:mobx/mobx.dart';

part 'fullscreen_store.g.dart';

class FullScreenStore = _FullScreenStoreBase with _$FullScreenStore;

abstract class _FullScreenStoreBase with Store {
  @observable
  bool fullscreen = false;

  @observable
  bool bottomBarVisible = true;

  @action
  void toggle() {
    fullscreen = !fullscreen;
  }

  @action
  void setBottomBarVisible(bool visible) {
    bottomBarVisible = visible;
  }
}
