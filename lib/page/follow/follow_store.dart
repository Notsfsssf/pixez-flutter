import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:mobx/mobx.dart';
import 'package:pixez/models/user_preview.dart';
import 'package:pixez/network/api_client.dart';

part 'follow_store.g.dart';

class FollowStore = _FollowStoreBase with _$FollowStore;

abstract class _FollowStoreBase with Store {
  final ApiClient client;

  final int id;
  final EasyRefreshController _controller;
  ObservableList<UserPreviews> userList = ObservableList();

  _FollowStoreBase(this.client, this.id, this._controller);

  String nextUrl;

  @action
  Future<void> fetch(String restrict) async {
    try {
      final response = await client.getUserFollowing(id, restrict);
      UserPreviewsResponse userPreviews =
          UserPreviewsResponse.fromJson(response.data);
      nextUrl = userPreviews.next_url;
      userList.clear();
      userList.addAll(userPreviews.user_previews);
      _controller.finishRefresh(success: true);
    } catch (e) {
      _controller.finishRefresh(success: false);
    }
  }

  @action
  Future<void> fetchNext() async {
    if (nextUrl != null && nextUrl.isNotEmpty) {
      try {
        final response = await client.getNext(nextUrl);
        UserPreviewsResponse userPreviews =
            UserPreviewsResponse.fromJson(response.data);
        nextUrl = userPreviews.next_url;
        userList.addAll(userPreviews.user_previews);
        _controller.finishLoad();
      } catch (e) {
        _controller.finishLoad(success: false);
      }
    } else {
      _controller.finishLoad(success: true, noMore: true);
    }
  }
}
