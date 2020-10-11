import 'package:mobx/mobx.dart';

part 'top_store.g.dart';

class TopStore = _TopStoreBase with _$TopStore;

abstract class _TopStoreBase with Store {
  @observable
  String topName;

  @action
  setTop(String name) {
    topName = name;
  }
}
