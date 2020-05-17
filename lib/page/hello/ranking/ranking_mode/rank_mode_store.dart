import 'package:flutter/foundation.dart';
import 'package:mobx/mobx.dart';
import 'package:pixez/models/illust.dart';
import 'package:pixez/models/recommend.dart';
import 'package:pixez/network/api_client.dart';
part 'rank_mode_store.g.dart';

class RankModeStore = _RankModeStoreBase with _$RankModeStore;

abstract class _RankModeStoreBase with Store {
  final ApiClient client;
  final String mode, date;
  _RankModeStoreBase(this.mode, this.date, this.client);

  @observable
  ObservableList<Illusts> illusts =ObservableList();
  @action
  Future<void> start() async {
    try {
      final response = await client.getIllustRanking(mode, date);
      Recommend recommend = Recommend.fromJson(response.data);
      illusts.addAll(recommend.illusts);
    } catch (e) {
    }
  }
}
