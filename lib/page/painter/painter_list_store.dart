import 'package:dio/dio.dart';
import 'package:mobx/mobx.dart';
import 'package:pixez/lighting/lighting_store.dart';
import 'package:pixez/models/user_preview.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

part 'painter_list_store.g.dart';

class PainterListStore = _PainterListStoreBase with _$PainterListStore;

abstract class _PainterListStoreBase with Store {
  ObservableList<UserPreviews> users = ObservableList();
  FutureGet source;
  String? nextUrl;
  final RefreshController _controller;

  _PainterListStoreBase(this._controller, this.source);

  @action
  fetch() async {
    nextUrl = null;
    _controller.headerMode?.value = RefreshStatus.refreshing;
    _controller.footerMode?.value = LoadStatus.idle;
    try {
      Response response = await source();
      UserPreviewsResponse userPreviewsResponse =
          UserPreviewsResponse.fromJson(response.data);
      nextUrl = userPreviewsResponse.next_url;
      final results = userPreviewsResponse.user_previews;
      users.clear();
      users.addAll(results);
      _controller.refreshCompleted();
    } catch (e) {
      _controller.refreshFailed();
    }
  }

  @action
  next() async {
    if (nextUrl != null && nextUrl!.isNotEmpty) {
      try {
        Response response = await apiClient.getNext(nextUrl!);
        UserPreviewsResponse userPreviewsResponse =
            UserPreviewsResponse.fromJson(response.data);
        nextUrl = userPreviewsResponse.next_url;
        final results = userPreviewsResponse.user_previews;
        users.addAll(results);
        _controller.loadComplete();
      } catch (e) {
        _controller.loadFailed();
      }
    } else {
      _controller.loadNoData();
    }
  }
}
