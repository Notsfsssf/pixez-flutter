import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pixez/component/painter_avatar.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/models/novel_recom_response.dart';
import 'package:pixez/models/novel_series_detail.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/novel/component/novel_bookmark_button.dart';
import 'package:pixez/page/novel/user/novel_users_page.dart';
import 'package:pixez/page/novel/viewer/novel_store.dart';
import 'package:pixez/page/novel/viewer/novel_viewer.dart';
import 'package:share_plus/share_plus.dart';

final novelSeriesProvider =
    NotifierProvider<NovelSeriesNotifier, NovelSeriesState?>(() {
  return NovelSeriesNotifier();
});

class NovelSeriesState {
  final NovelSeriesDetail novelSeriesDetail;
  final List<Novel> novels;
  final List<NovelStore> novelStores;
  final String? nextUrl;

  NovelSeriesState(
      this.novelSeriesDetail, this.novels, this.novelStores, this.nextUrl);
}

class NovelSeriesNotifier extends Notifier<NovelSeriesState?> {
  final EasyRefreshController refreshController = EasyRefreshController();

  Future<void> fetch(int id) async {
    try {
      final response = await apiClient.novelSeries(id);
      final detail = NovelSeriesResponse.fromJson(response.data);
      final list = detail.novels.map((e) => NovelStore(e.id, e)).toList();
      final result = NovelSeriesState(
          detail.novelSeriesDetail, detail.novels, list, detail.nextUrl);
      state = result;
      refreshController.finishRefresh();
    } catch (e) {
      print(e);
      refreshController.finishRefresh(IndicatorResult.fail);
    }
  }

  Future<void> onLoadNext() async {
    if (state?.nextUrl != null) {
      try {
        final response = await apiClient.getNext(state!.nextUrl!);
        final detail = NovelSeriesResponse.fromJson(response.data);
        final list = detail.novels.map((e) => NovelStore(e.id, e)).toList();
        final result = NovelSeriesState(
            detail.novelSeriesDetail,
            state!.novels + detail.novels,
            state!.novelStores + list,
            detail.nextUrl);
        state = result;
        refreshController.finishLoad(
            IndicatorResult.success);
      } catch (e) {
        print(e);
        refreshController.finishLoad(IndicatorResult.fail);
      }
    } else {
      refreshController.finishLoad(IndicatorResult.success);
    }
  }

  @override
  NovelSeriesState? build() {
    return null;
  }
}

class NovelSeriesPage extends HookConsumerWidget {
  final int id;
  const NovelSeriesPage(this.id, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(novelSeriesProvider);
    final refreshState = useState(0);
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          if (data != null) ...[
            PainterAvatar(
              url: data.novelSeriesDetail.user.profileImageUrls.medium,
              id: data.novelSeriesDetail.user.id,
              size: Size(30, 30),
              onTap: () {
                Leader.push(context,
                    NovelUsersPage(id: data.novelSeriesDetail.user.id));
              },
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                "${data.novelSeriesDetail.user.name}",
                style: Theme.of(context).textTheme.titleSmall,
              ),
            )
          ]
        ]),
        actions: [
          Builder(builder: (context) {
            return IconButton(
                onPressed: () {
                  final box = context.findRenderObject() as RenderBox?;
                  final pos = box != null
                      ? box.localToGlobal(Offset.zero) & box.size
                      : null;
                  Share.share("https://www.pixiv.net/novel/series/$id",
                      sharePositionOrigin: pos);
                },
                icon: Icon(Icons.share));
          })
        ],
      ),
      body: EasyRefresh(
        refreshOnStart: true,
        controller: ref.read(novelSeriesProvider.notifier).refreshController,
        onLoad: () async {
          await ref.read(novelSeriesProvider.notifier).onLoadNext();
        },
        child: Builder(builder: (context) {
          if (data != null)
            return Container(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        Container(
                          height: 60,
                        ),
                        SelectionArea(
                          child: Text(
                            "${data.novelSeriesDetail.title}",
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        SelectionArea(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              "${data.novelSeriesDetail.caption ?? ""}",
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ),
                      ],
                      crossAxisAlignment: CrossAxisAlignment.center,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Column(children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: FilledButton.tonal(
                              onPressed: () {
                                Leader.push(context,
                                    NovelViewerPage(id: data.novels.last.id));
                              },
                              child: Text(I18n.of(context).view_the_latest)),
                        ),
                      ),
                      Divider()
                    ]),
                  ),
                  SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                    final novel = data.novels[index];
                    return _buildItem(context, novel, data.novelStores[index],
                        index, refreshState);
                  }, childCount: data.novels.length))
                ],
              ),
            );
          return CustomScrollView(
            slivers: [],
          );
        }),
        onRefresh: () async {
          await ref.read(novelSeriesProvider.notifier).fetch(id);
        },
      ),
    );
  }

  Widget _buildItem(BuildContext context, Novel novel, NovelStore novelStore,
      int index, ValueNotifier<int> refreshState) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Card(
        child: InkWell(
          onTap: () async {
            await Navigator.of(context, rootNavigator: true)
                .push(MaterialPageRoute(
                    builder: (BuildContext context) => NovelViewerPage(
                          id: novel.id,
                          novelStore: novelStore,
                        )));
            refreshState.value = refreshState.value + 1;
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 5,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: PixivImage(
                        novel.imageUrls.medium,
                        width: 80,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0, left: 8.0),
                            child: Text(
                              "#${index + 1} ${novel.title}",
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyLarge,
                              maxLines: 3,
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              novel.user.name,
                              maxLines: 1,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 2, // gap between adjacent chips
                              runSpacing: 0,
                              children: [
                                for (var f in novel.tags)
                                  Text(
                                    f.name,
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  )
                              ],
                            ),
                          ),
                          Container(
                            height: 8.0,
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    NovelBookmarkButton(novel: novelStore.novel!),
                    Text('${novel.totalBookmarks}',
                        style: Theme.of(context).textTheme.bodySmall)
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
