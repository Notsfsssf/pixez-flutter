import 'package:dio/dio.dart';
import 'package:mobx/mobx.dart';
import 'package:pixez/models/illust.dart';
import 'package:pixez/models/recommend.dart';
import 'package:pixez/network/api_client.dart';
part 'illust_about_store.g.dart';

class IllustAboutStore = _IllustAboutStoreBase with _$IllustAboutStore;

abstract class _IllustAboutStoreBase with Store {
  final int id;

  _IllustAboutStoreBase(this.id);
  @observable
  String errorMessage;

  ObservableList<Illusts> illusts = ObservableList();
  fetch() async {
    errorMessage = null;
    try {
      Response response = await apiClient.getIllustRelated(id);
      Recommend recommend = Recommend.fromJson(response.data);
      illusts.clear();
      illusts.addAll(recommend.illusts);
    } catch (e) {
      if (e != null) {
        errorMessage = e.toString();
      }
    }
  }
}
