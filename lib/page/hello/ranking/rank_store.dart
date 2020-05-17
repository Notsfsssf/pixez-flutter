import 'package:mobx/mobx.dart';
import 'package:shared_preferences/shared_preferences.dart';
part 'rank_store.g.dart';

class RankStore = _RankStoreBase with _$RankStore;

abstract class _RankStoreBase with Store {
  static const MODE_LIST = 'mode_list';
  List<String> intialModeList = [
    "day",
    "day_male",
    "day_female",
    "week_original",
    "week_rookie",
    "week",
    "month",
    "day_r18",
    "week_r18"
  ];
  @observable
  ObservableList<String> modeList = ObservableList();
  @observable
  bool modifyUI = false;

  @action
  Future<void> reset() async {
    var pre = await SharedPreferences.getInstance();
    await pre.remove(MODE_LIST);
    modeList.clear();
  }

  SharedPreferences pre;
  @action
  Future<void> init() async {
    pre = await SharedPreferences.getInstance();
    var list = pre.getStringList(MODE_LIST);
    if (list == null || list.isEmpty) {
      return;
    }
    modeList.clear();
    modeList.addAll(list);
  }

  @action
  Future<void> saveChange(Map<String, bool> selectMap) async {
    var pre = await SharedPreferences.getInstance();
    List<String> saveList = [];
    selectMap.forEach((s, b) {
      if (b) saveList.add(s);
    });
    await pre.setStringList(MODE_LIST, saveList);
    modeList.clear();
    modeList.addAll(saveList);
  }
}
