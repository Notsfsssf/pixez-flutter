import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pixez/lighting/lighting_store.dart';
import 'package:pixez/models/illust.dart';
import 'package:pixez/models/recommend.dart';
import 'package:pixez/network/api_client.dart';

class IllustListNotifier extends StateNotifier<List<Illusts>> {
  final Ref ref;
  IllustListNotifier(this.ref) : super([]);

  int currentPage = 0;
  int? nextCursor;

  fetch() async {
    try {
      nextCursor = null;
      final response =
          await apiClient.getUserIllustsOffset(420509, "illust", nextCursor);
      Recommend recommend = Recommend.fromJson(response.data);
      print(recommend.nextUrl);
      nextCursor =
          recommend.illusts.length < 30 ? null : recommend.illusts.length;
      state = recommend.illusts;
    } catch (e) {}
  }

  next() async {
    try {
      if (nextCursor == null) return;
      final response =
          await apiClient.getUserIllustsOffset(420509, "illust", nextCursor);
      Recommend recommend = Recommend.fromJson(response.data);
      state = [...state, ...recommend.illusts];
      nextCursor = recommend.illusts.length < 30 ? null : state.length;
    } catch (e) {}
  }
}
