import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pixez/models/illust.dart';
import 'package:pixez/models/recommend.dart';
import 'package:pixez/network/api_client.dart';

class IllustListState {
  final List<Illusts> illusts;
  final int? preCursor;
  final int? nextCursor;

  IllustListState(this.illusts, this.preCursor, this.nextCursor);
}

class IllustListNotifier extends StateNotifier<IllustListState> {
  final Ref ref;
  IllustListNotifier(this.ref) : super(IllustListState([], null, null));

  fetch({int offset = 0}) async {
    try {
      final response = await apiClient.getUserIllustsOffset(
          420509, "illust", offset < 30 ? null : offset);
      Recommend recommend = Recommend.fromJson(response.data);
      final preCursor = (offset - recommend.illusts.length) < 30
          ? null
          : (offset - recommend.illusts.length);
      final nextCursor = recommend.illusts.length < 30
          ? null
          : (offset += recommend.illusts.length);
      state = IllustListState(recommend.illusts, preCursor, nextCursor);
    } catch (e) {}
  }

  pre() async {
    try {
      if (state.preCursor == null) return;
      final response = await apiClient.getUserIllustsOffset(
          420509, "illust", state.preCursor);
      Recommend recommend = Recommend.fromJson(response.data);
      final illusts = [...recommend.illusts, ...state.illusts];
      final preCursorOffset = state.preCursor! - recommend.illusts.length;
      final preOffset = (preCursorOffset < 30) ? null : preCursorOffset;
      state = IllustListState(illusts, preOffset, state.nextCursor);
    } catch (e) {}
  }

  next() async {
    try {
      if (state.nextCursor == null) return;
      final response = await apiClient.getUserIllustsOffset(
          420509, "illust", state.nextCursor);
      Recommend recommend = Recommend.fromJson(response.data);
      final illusts = [...state.illusts, ...recommend.illusts];
      final nextCursor = recommend.illusts.length < 30 ? null : illusts.length;
      state = IllustListState(illusts, state.nextCursor, nextCursor);
    } catch (e) {}
  }
}
