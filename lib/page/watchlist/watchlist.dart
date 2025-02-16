import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pixez/component/pixez_default_header.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/exts.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/models/watchlist_manga_model.dart';
import 'package:pixez/page/picture/illust_lighting_page.dart';
import 'package:pixez/page/series/illust_series_page.dart';
import 'package:pixez/page/watchlist/watchlist_notifier.dart';

class WatchlistPage extends StatefulHookConsumerWidget {
  const WatchlistPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _State();
}

class _State extends ConsumerState<WatchlistPage> {
  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(watchlistStoreProvider.notifier).controller;
    final mangaSeries =
        ref.watch(watchlistStoreProvider.select((e) => e.mangaSeries));
    useEffect(() {
      Future.delayed(Duration.zero, () {
        ref.read(watchlistStoreProvider.notifier).fetch();
      });
      return null;
    }, []);
    return EasyRefresh.builder(
      controller: controller,
      header: PixezDefault.header(context),
      footer: PixezDefault.footer(context),
      onRefresh: () async {
        await ref.read(watchlistStoreProvider.notifier).fetch();
      },
      onLoad: () async {
        await ref.read(watchlistStoreProvider.notifier).loadMore();
      },
      childBuilder: (context, physics) {
        return CustomScrollView(
          physics: physics,
          slivers: [
            SliverList(
                delegate: SliverChildBuilderDelegate(
              (context, index) {
                return MangaSeriesItem(data: mangaSeries[index]);
              },
              childCount: mangaSeries.length,
            )),
          ],
        );
      },
    );
  }
}

class MangaSeriesItem extends StatelessWidget {
  final MangaSeriesModel data;
  const MangaSeriesItem({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Leader.push(context, IllustSeriesPage(id: data.id));
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
                              IllustLightingPage(id: data.latestContentId));
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
