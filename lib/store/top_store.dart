import 'dart:async';

import 'package:mobx/mobx.dart';
import 'package:pixez/er/lprinter.dart';

part 'top_store.g.dart';

class TopStore = _TopStoreBase with _$TopStore;

abstract class _TopStoreBase with Store {
  late StreamController<String> _streamController;

  late ObservableStream<String> topStream;

  _TopStoreBase() {
    _streamController = StreamController();
    topStream = ObservableStream(_streamController.stream.asBroadcastStream());
  }

  @observable
  int code = 0;

  @action
  setCode(int code) {
    this.code = code;
  }

  dispose() {
    _streamController?.close();
  }

  setTop(String name) {
    LPrinter.d(name);
    _streamController.add(name);
  }
}
