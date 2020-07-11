import 'package:dio/dio.dart';
import 'package:mobx/mobx.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/error_message.dart';
import 'package:pixez/models/illust.dart';
import 'package:pixez/network/api_client.dart';
part 'illust_store.g.dart';

class IllustStore = _IllustStoreBase with _$IllustStore;

abstract class _IllustStoreBase with Store {
  final int id;
  final ApiClient client = apiClient;
  @observable
  Illusts illusts;
  @observable
  bool isBookmark;
  @observable
  String errorMessage;
  _IllustStoreBase(this.id, this.illusts) {
    isBookmark = illusts?.isBookmarked ?? false;
  }
  @action
  fetch() async {
    errorMessage = null;
    if (illusts == null) {
      try {
        Response response = await client.getIllustDetail(id);

        final result = Illusts.fromJson(response.data['illust']);

        illusts = result;
      } on DioError catch (e) {
        if (e.response != null) {
          errorMessage = ErrorMessage.fromJson(e.response.data).error.message;
        } else {
          errorMessage = e.toString();
        }
      }
    }
    if (illusts != null) historyStore.insert(illusts);
  }

  @action
  Future<bool> star({String restrict = 'public', List<String> tags}) async {
    if (!illusts.isBookmarked) {
      try {
        Response response =
            await client.postLikeIllust(illusts.id, restrict, tags);
        illusts.isBookmarked = true;
        isBookmark = true;
        return true;
      } catch (e) {}
    } else {
      try {
        Response response = await client.postUnLikeIllust(illusts.id);
        illusts.isBookmarked = false;
        isBookmark = false;
        return false;
      } catch (e) {}
    }
    return null;
  }
}
