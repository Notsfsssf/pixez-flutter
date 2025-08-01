import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pixez/component/pixez_default_header.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/exts.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/models/novel_watch_list_model.dart';
import 'package:pixez/page/novel/new/novel_watch_list_notifier.dart';
import 'package:pixez/page/novel/series/novel_series_page.dart';
import 'package:pixez/page/novel/viewer/novel_viewer.dart';
import 'package:pixez/page/picture/illust_lighting_page.dart';

class NovelWatchList extends StatefulHookConsumerWidget {
  const NovelWatchList({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _State();
}

class _State extends ConsumerState<NovelWatchList> {
  @override
  Widget build(BuildContext context) {
    final controller =
        ref.watch(novelWatchListStoreProvider.notifier).controller;
    final series =
        ref.watch(novelWatchListStoreProvider.select((e) => e.series));
    useEffect(() {
      Future.delayed(Duration.zero, () {
        ref.read(novelWatchListStoreProvider.notifier).fetch();
      });
      return null;
    }, []);
    return EasyRefresh.builder(
      controller: controller,
      header: PixezDefault.header(context),
      footer: PixezDefault.footer(context),
      onRefresh: () async {
        ref.read(novelWatchListStoreProvider.notifier).fetch();
      },
      onLoad: () async {
        ref.read(novelWatchListStoreProvider.notifier).loadMore();
      },
      childBuilder: (context, physics) {
        return CustomScrollView(
          physics: physics,
          slivers: [
            SliverList(
                delegate: SliverChildBuilderDelegate(
              (context, index) {
                return NovelSeriesItem(data: series[index]);
              },
              childCount: series.length,
            )),
          ],
        );
      },
    );
  }
}

class NovelSeriesItem extends StatelessWidget {
  final NovelSeriesModel data;
  const NovelSeriesItem({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Leader.push(context, NovelSeriesPage(data.id));
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          SizedBox(
            height: 12,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  constraints: BoxConstraints(minHeight: 120),
                  child: Stack(
                    children: [
                      PixivImage(
                        data.url ?? '',
                        width: 120,
                        fit: BoxFit.fitWidth,
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          margin: EdgeInsets.only(top: 4, right: 4),
                          padding:
                              EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          child: Text('${data.publishedContentCount}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 12,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(data.title,
                      style: Theme.of(context).textTheme.titleMedium),
                  Row(
                    children: [
                      Text(
                        data.user?.name ?? '',
                        style: Theme.of(context).textTheme.labelLarge,
                      )
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(data.lastPublishedContentDatetime.toShortTime(),
                      style: Theme.of(context).textTheme.bodySmall),
                  SizedBox(height: 8),
                  ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: InkWell(
                        onTap: () {
                          Leader.push(context,
                              NovelViewerPage(id: data.latestContentId));
                        },
                        child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            child: Text(I18n.of(context).view_latest,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(color: Colors.white))),
                      ))
                ],
              ),
            ],
          ),
          Divider()
        ],
      ),
    );
  }
}
