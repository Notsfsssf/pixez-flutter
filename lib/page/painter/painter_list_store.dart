import 'package:dio/dio.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:mobx/mobx.dart';
import 'package:pixez/lighting/lighting_store.dart';
import 'package:pixez/models/user_preview.dart';
import 'package:pixez/network/api_client.dart';

part 'painter_list_store.g.dart';

class PainterListStore = _PainterListStoreBase with _$PainterListStore;

abstract class _PainterListStoreBase with Store {
  ObservableList<UserPreviews> users = ObservableList();
  FutureGet source;
  String? nextUrl;
  final EasyRefreshController _controller;

  _PainterListStoreBase(this._controller, this.source);

  @action
  fetch() async {
    nextUrl = null;
    try {
      Response response = await source();
      UserPreviewsResponse userPreviewsResponse =
          UserPreviewsResponse.fromJson(response.data);
      nextUrl = userPreviewsResponse.next_url;
      final results = userPreviewsResponse.user_previews;
      users.clear();
      users.addAll(results);
      _controller.finishRefresh(IndicatorResult.success);
    } catch (e) {
      _controller.finishRefresh(IndicatorResult.fail);
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
        _controller.finishLoad(IndicatorResult.success);
      } catch (e) {
        _controller.finishLoad(IndicatorResult.fail);
      }
    } else {
        _controller.finishLoad(IndicatorResult.noMore);
    }
  }
}
