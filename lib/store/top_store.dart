import 'package:mobx/mobx.dart';
import 'package:pixez/er/lprinter.dart';

part 'top_store.g.dart';

class TopStore = _TopStoreBase with _$TopStore;

abstract class _TopStoreBase with Store {
  @observable
  String topName;

  @observable
  int code = 0;

  @action
  setCode(int code) {
    this.code = code;
  }

  @action
  setTop(String name) {
    LPrinter.d(name);
    topName = "";
    topName = name;
  }
}
