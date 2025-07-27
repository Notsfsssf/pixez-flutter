import 'package:easy_refresh/easy_refresh.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pixez/models/novel_watch_list_model.dart';
import 'package:pixez/network/api_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'novel_watch_list_notifier.freezed.dart';
part 'novel_watch_list_notifier.g.dart';

@freezed
class NovelWatchListState with _$NovelWatchListState {
  const factory NovelWatchListState({
    @Default([]) List<NovelSeriesModel> series,
    NovelWatchListModel? model,
    String? errorMessage,
    @Default(false) bool isLoading,
  }) = _NovelWatchListState;
}

@riverpod
class NovelWatchListStore extends _$NovelWatchListStore {
  EasyRefreshController controller = EasyRefreshController(
    controlFinishLoad: true,
    controlFinishRefresh: true,
  );
  @override
  NovelWatchListState build() {
    return const NovelWatchListState();
  }

  Future<void> fetch() async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await apiClient.watchListNovel();
      final data = NovelWatchListModel.fromJson(response.data);
      final nextUrl = data.nextUrl;
      controller.finishRefresh(IndicatorResult.success);
      if (nextUrl != null) {
        controller.resetFooter();
      }
      state =
          state.copyWith(series: data.series, model: data, isLoading: false);
    } catch (e) {
      controller.finishRefresh(IndicatorResult.fail);
      state = state.copyWith(errorMessage: e.toString(), isLoading: false);
    }
  }

  // load more
  Future<void> loadMore() async {
    try {
      var nextUrl = state.model?.nextUrl;
      if (nextUrl == null) {
        controller.finishLoad(IndicatorResult.noMore);
        return;
      }
      final response = await apiClient.getNext(nextUrl);
      final data = NovelWatchListModel.fromJson(response.data);
      state = state.copyWith(
        model: data,
        series: [
          ...state.series,
          ...data.series,
        ],
        isLoading: false,
      );
      nextUrl = data.nextUrl;
      controller.finishLoad(
          nextUrl != null ? IndicatorResult.success : IndicatorResult.noMore);
    } catch (e) {
      controller.finishLoad(IndicatorResult.fail);
      state = state.copyWith(errorMessage: e.toString(), isLoading: false);
    }
  }
}
