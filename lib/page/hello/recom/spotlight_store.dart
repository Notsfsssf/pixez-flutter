import 'package:dio/dio.dart';
import 'package:mobx/mobx.dart';
import 'package:pixez/models/spotlight_response.dart';
import 'package:pixez/network/api_client.dart';

part 'spotlight_store.g.dart';

class SpotlightStore = _SpotlightStoreBase with _$SpotlightStore;

abstract class _SpotlightStoreBase with Store {
  final ApiClient client;
  ObservableList<SpotlightArticle> articles = ObservableList();
  String nextUrl;

  _SpotlightStoreBase(this.client);

  @action
  Future<void> fetch() async {
    try {
      Response response = await client.getSpotlightArticles("all");
      final result = SpotlightResponse.fromJson(response.data);
      articles.clear();
      articles.addAll(result.spotlightArticles);
      nextUrl = result.nextUrl;
    } catch (e) {}
  }
}
