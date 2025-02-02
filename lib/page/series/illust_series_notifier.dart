
import 'package:easy_refresh/easy_refresh.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pixez/models/illust_series_with_id_model.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/picture/illust_store.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'illust_series_notifier.freezed.dart';
part 'illust_series_notifier.g.dart';

@freezed
class IllustSeriesState with _$IllustSeriesState {
  const factory IllustSeriesState({
    @Default(false) bool isLoading,
    IllustSeriesWithIdModel? model,
    @Default([]) List<IllustStore> illusts,
    @Default(false) bool watchlistAdded,
    String? errorMessage,
  }) = _IllustSeriesState;
}

@riverpod
class IllustSeriesStore extends _$IllustSeriesStore {
  EasyRefreshController controller = EasyRefreshController(
      controlFinishLoad: true, controlFinishRefresh: true);
  late int id;
  @override
  IllustSeriesState build(int id) {
    this.id = id;
    return IllustSeriesState();
  }

  Future<void> fetch() async {
    try {
      state = state.copyWith(isLoading: true);
      final response = await apiClient.illustSeries(id);
      final model = IllustSeriesWithIdModel.fromJson(response.data);
      final nextUrl = model.nextUrl;
      controller.finishRefresh(
          nextUrl != null ? IndicatorResult.success : IndicatorResult.noMore);
      state = state.copyWith(
          isLoading: false,
          model: model,
          watchlistAdded: model.illustSeriesDetail?.watchlistAdded ?? false,
          illusts: [...model.illusts?.map((e) => IllustStore(e.id, e)) ?? []],
          errorMessage: null);
    } catch (e) {
      controller.finishRefresh(IndicatorResult.fail);
      state = state.copyWith(
          isLoading: false, errorMessage: e.toString(), watchlistAdded: false);
    }
  }

  // loadmore
  Future<void> loadMore() async {
    try {
      final nextUrl = state.model?.nextUrl;
      if (nextUrl == null) {
        controller.finishLoad(IndicatorResult.noMore);
        return;
      }
      final response = await apiClient.getNext(nextUrl);
      final model = IllustSeriesWithIdModel.fromJson(response.data);
      controller.finishLoad(state.model?.nextUrl != null
          ? IndicatorResult.success
          : IndicatorResult.noMore);
      state = state.copyWith(
          model: model,
          illusts: [
            ...state.illusts,
            ...model.illusts?.map((e) => IllustStore(e.id, e)) ?? []
          ],
          errorMessage: null);
    } catch (e) {
      controller.finishLoad(IndicatorResult.fail);
    }
  }

  Future<void> removeWatchlist() async {
    try {
      await apiClient.watchListMangaDelete(id);
      state = state.copyWith(watchlistAdded: false);
    } catch (e) {}
  }

  Future<void> addWatchlist() async {
    try {
      await apiClient.watchListMangaAdd(id);
      state = state.copyWith(watchlistAdded: true);
    } catch (e) {}
  }
}
