import 'package:mobx/mobx.dart';
import 'package:pixez/models/ban_illust_id.dart';
import 'package:pixez/models/ban_tag.dart';
import 'package:pixez/models/ban_user_id.dart';

part 'mute_store.g.dart';

class MuteStore = _MuteStoreBase with _$MuteStore;

abstract class _MuteStoreBase with Store {
  BanIllustIdProvider banIllustIdProvider = BanIllustIdProvider();
  var banUserIdProvider = BanUserIdProvider();
  var banTagProvider = BanTagProvider();
  ObservableList<BanUserIdPersist> banUserIds = ObservableList();

  _MuteStoreBase() {
    fetchBanUserIds();
  }

  @action
  Future<void> fetchBanUserIds() async {
    await banUserIdProvider.open();
    List<BanUserIdPersist> userids = await banUserIdProvider.getAllAccount();
    banUserIds.clear();
    banUserIds.addAll(userids);
  }

  @action
  Future<void> insertBanUserId(String id, String name) async {
    await banUserIdProvider.open();
    await banUserIdProvider.insert(BanUserIdPersist()
      ..userId = id
      ..name = name);
    await fetchBanUserIds();
  }

  @action
  Future<void> deleteBanUserId(int id) async {
    await banUserIdProvider.open();
    await banUserIdProvider.delete(id);
    await fetchBanUserIds();
  }
}
