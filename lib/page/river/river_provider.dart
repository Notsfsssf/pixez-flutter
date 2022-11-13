import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pixez/lighting/lighting_store.dart';
import 'package:pixez/models/illust.dart';
import 'package:pixez/models/recommend.dart';
import 'package:pixez/network/api_client.dart';

class IllustListNotifier extends StateNotifier<List<Illusts>> {
  final Ref ref;
  final ApiSource source;
  IllustListNotifier(this.ref, this.source) : super([]);

  int currentPage = 0;

  fetch() async {
    try {
      final response = await source.fetch();
      Recommend recommend = Recommend.fromJson(response.data);
      recommend.illusts;
      print(recommend.nextUrl);
      state = recommend.illusts;
    } catch (e) {}
  }

  next() async {
    try {
      final response = await apiClient.getRecommend();
      Recommend recommend = Recommend.fromJson(response.data);
      recommend.illusts;
      state = [...state, ...recommend.illusts];
    } catch (e) {}
  }
}
