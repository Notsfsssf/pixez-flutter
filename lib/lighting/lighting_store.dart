import 'package:dio/dio.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:mobx/mobx.dart';
import 'package:pixez/models/illust.dart';
import 'package:pixez/models/recommend.dart';
import 'package:pixez/network/api_client.dart';

part 'lighting_store.g.dart';

class LightingStore = _LightingStoreBase with _$LightingStore;
typedef Future<Response> FutureGet();

abstract class _LightingStoreBase with Store {
  final ApiClient _apiClient;
  final EasyRefreshController _controller;
  FutureGet source;

  String nextUrl;
  @observable
  ObservableList<Illusts> illusts = ObservableList();

  _LightingStoreBase(
    this.source,
    this._apiClient,
    this._controller,
  );

  @action
  fetch() async {
    nextUrl=null;
    try {
      final result = await source();
      Recommend recommend = Recommend.fromJson(result.data);
      nextUrl = recommend.nextUrl;
      illusts.clear();
      illusts.addAll(recommend.illusts);
      _controller.finishRefresh(success: true);
    } catch (e) {
      _controller.finishRefresh(success: false);
    }
  }

  @action
  fetchNext() async {
    try {
      if (nextUrl != null && nextUrl.isNotEmpty) {
        Response result = await _apiClient.getNext(nextUrl);
        Recommend recommend = Recommend.fromJson(result.data);
        nextUrl = recommend.nextUrl;
        illusts.addAll(recommend.illusts);
        _controller.finishLoad(success: true, noMore: false);
      } else {
        _controller.finishLoad(success: true, noMore: true);
      }
    } catch (e) {
      _controller.finishLoad(success: false);
    }
  }
}
