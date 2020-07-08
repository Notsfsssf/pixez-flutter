import 'package:dio/dio.dart';
import 'package:mobx/mobx.dart';
import 'package:pixez/models/illust.dart';
import 'package:pixez/network/api_client.dart';
part 'illust_detail_store.g.dart';

class IllustDetailStore = _IllustDetailStoreBase with _$IllustDetailStore;

abstract class _IllustDetailStoreBase with Store {
  final Illusts illust;
  @observable
  bool isFollow;

  _IllustDetailStoreBase(this.illust) {
    isFollow = illust.user.isFollowed;
  }
  @action
  followUser() async {
    try {
      if (illust.user.isFollowed) {
        Response response = await apiClient.postUnFollowUser(illust.user.id);
        illust.user.isFollowed = false;
        isFollow = false;
      } else {
        Response response =
            await apiClient.postFollowUser(illust.user.id, 'public');
        illust.user.isFollowed = true;
        isFollow = true;
      }
    } catch (e) {}
  }
}
