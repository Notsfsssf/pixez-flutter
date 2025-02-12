import 'package:easy_refresh/easy_refresh.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pixez/models/watchlist_manga_model.dart';
import 'package:pixez/network/api_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'watchlist_notifier.freezed.dart';
part 'watchlist_notifier.g.dart';

@freezed
class WatchlistState with _$WatchlistState {
  const factory WatchlistState({
    @Default([]) List<MangaSeriesModel> mangaSeries,
    WatchlistMangaModel? model,
    String? errorMessage,
    @Default(false) bool isLoading,
  }) = _WatchlistState;
}

@riverpod
class WatchlistStore extends _$WatchlistStore {
  EasyRefreshController controller = EasyRefreshController(
    controlFinishLoad: true,
    controlFinishRefresh: true,
  );
  @override
  WatchlistState build() {
    return const WatchlistState();
  }

  Future<void> fetch() async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await apiClient.watchListManga();
      final data = WatchlistMangaModel.fromJson(response.data);
      final nextUrl = data.nextUrl;
      controller.finishRefresh(
          nextUrl != null ? IndicatorResult.success : IndicatorResult.noMore);
      state = state.copyWith(mangaSeries: data.series, isLoading: false);
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
      final data = WatchlistMangaModel.fromJson(response.data);
      state = state.copyWith(
        model: data,
        mangaSeries: [
          ...state.mangaSeries,
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
