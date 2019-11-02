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

  bool _lock = false;
  @action
  Future<bool> fetch() async {
    if (_lock) return false;
    _lock = true;
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
      return true;
    } catch (e) {
      _controller.finishRefresh(IndicatorResult.fail);
      return false;
    } finally {
      _lock = false;
    }
  }

  @action
  Future<bool> next() async {
    if (_lock) return false;
    _lock = true;
    try {
      if (nextUrl != null && nextUrl!.isNotEmpty) {
        try {
          Response response = await apiClient.getNext(nextUrl!);
          UserPreviewsResponse userPreviewsResponse =
              UserPreviewsResponse.fromJson(response.data);
          nextUrl = userPreviewsResponse.next_url;
          final results = userPreviewsResponse.user_previews;
          users.addAll(results);
          _controller.finishLoad(IndicatorResult.success);
          return true;
        } catch (e) {
          _controller.finishLoad(IndicatorResult.fail);
          return false;
        }
      } else {
        _controller.finishLoad(IndicatorResult.noMore);
        return true;
      }
    } finally {
      _lock = false;
    }
  }
}
