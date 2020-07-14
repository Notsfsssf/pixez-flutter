import 'package:mobx/mobx.dart';
import 'package:pixez/models/novel_text_response.dart';
import 'package:pixez/network/api_client.dart';
part 'novel_store.g.dart';

class NovelStore = _NovelStoreBase with _$NovelStore;

abstract class _NovelStoreBase with Store {
  final int id;

  _NovelStoreBase(this.id);
  @observable
  NovelTextResponse novelTextResponse;
  @action
  fetch() async {
    try {
      var response = await apiClient.getNovelText(id);
      novelTextResponse = NovelTextResponse.fromJson(response.data);
    } catch (e) {}
  }
}
