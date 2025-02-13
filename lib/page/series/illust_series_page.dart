import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pixez/component/null_hero.dart';
import 'package:pixez/component/pixez_default_header.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/component/star_icon.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/illust.dart';
import 'package:pixez/page/picture/illust_lighting_page.dart';
import 'package:pixez/page/picture/illust_store.dart';
import 'package:pixez/page/series/illust_series_notifier.dart';
import 'package:pixez/page/user/users_page.dart';
import 'package:share_plus/share_plus.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

class IllustSeriesPage extends StatefulHookConsumerWidget {
  final int id;

  const IllustSeriesPage({super.key, required this.id});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _IllustSeriesPageState();
}

class _IllustSeriesPageState extends ConsumerState<IllustSeriesPage> {
  late int id = widget.id;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final model =
        ref.watch(illustSeriesStoreProvider(widget.id).select((e) => e.model));
    final isLoading = ref
        .watch(illustSeriesStoreProvider(widget.id).select((e) => e.isLoading));
    final coverImageUrl = model?.illustSeriesDetail?.coverImageUrls?.medium;
    final caption = kDebugMode
        ? "wfaefafawefawfewaefaweewafawefaweffwafewfwafwafwafwfe"
        : (model?.illustSeriesDetail?.caption);
    final illusts = ref
        .watch(illustSeriesStoreProvider(widget.id).select((e) => e.illusts));
    final watchListAdded = ref.watch(
        illustSeriesStoreProvider(widget.id).select((e) => e.watchlistAdded));
    final errorMessage = ref.watch(
        illustSeriesStoreProvider(widget.id).select((e) => e.errorMessage));
    final profileUrl =
        model?.illustSeriesDetail?.user?.profileImageUrls?.medium;
    final controller =
        ref.read(illustSeriesStoreProvider(widget.id).notifier).controller;

    useEffect(() {
      Future.delayed(Duration.zero, () {
        ref.read(illustSeriesStoreProvider(widget.id).notifier).fetch();
      });
      return null;
    }, []);
    return Scaffold(
      appBar: AppBar(
        actions: [
          Builder(builder: (context) {
            return IconButton(
              onPressed: () {
                final userId = model?.illustSeriesDetail?.user?.id;
                final seriesId = model?.illustSeriesDetail?.id;
                if (userId != null && seriesId != null) {
                  final box = context.findRenderObject() as RenderBox?;
                  final pos = box != null
                      ? box.localToGlobal(Offset.zero) & box.size
                      : null;
                  final link =
                      "https://www.pixiv.net/user/$userId/series/$seriesId";
                  Share.share(link, sharePositionOrigin: pos);
                }
              },
              icon: Icon(Icons.share),
            );
          })
        ],
      ),
      body: Container(
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : errorMessage != null
                ? _buildErrorContent(context, errorMessage)
                : EasyRefresh.builder(
                    controller: controller,
                    header: PixezDefault.header(context),
                    footer: PixezDefault.footer(context),
                    onRefresh: () async {
                      await ref
                          .read(illustSeriesStoreProvider(widget.id).notifier)
                          .fetch();
                    },
                    onLoad: () async {
                      await ref
                          .read(illustSeriesStoreProvider(widget.id).notifier)
                          .loadMore();
                    },
                    childBuilder: (context, physics) {
                      return CustomScrollView(
                        physics: physics,
                        slivers: [
                          SliverToBoxAdapter(
                            child: Column(
                              children: [
                                Container(
                                  height: 140,
                                  child: coverImageUrl == null
                                      ? Container()
                                      : PixivImage(
                                          coverImageUrl,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                        ),
                                ),
                                Container(
                                  alignment: Alignment.center,
                                  margin: EdgeInsets.only(left: 16, right: 16),
                                  child: Text(
                                      model?.illustSeriesDetail?.title ?? "",
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          )),
                                ),
                                SizedBox(
                                  height: 4,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Leader.push(
                                        context,
                                        UsersPage(
                                            id: model?.illustSeriesDetail?.user
                                                    ?.id ??
                                                0));
                                  },
                                  behavior: HitTestBehavior.opaque,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (profileUrl != null) ...[
                                        ClipOval(
                                          child: PixivImage(
                                            profileUrl,
                                            width: 24,
                                            height: 24,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 4,
                                        ),
                                      ],
                                      Text(
                                        model?.illustSeriesDetail?.user?.name ??
                                            "",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 12,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    if (watchListAdded) {
                                      ref
                                          .read(illustSeriesStoreProvider(
                                                  widget.id)
                                              .notifier)
                                          .removeWatchlist();
                                    } else {
                                      ref
                                          .read(illustSeriesStoreProvider(
                                                  widget.id)
                                              .notifier)
                                          .addWatchlist();
                                    }
                                  },
                                  behavior: HitTestBehavior.opaque,
                                  child: Container(
                                    decoration: watchListAdded
                                        ? BoxDecoration(
                                            border: Border.all(
                                                color: Colors.black, width: 1),
                                            borderRadius:
                                                BorderRadius.circular(21),
                                          )
                                        : BoxDecoration(
                                            color: Colors.blue,
                                            borderRadius:
                                                BorderRadius.circular(21)),
                                    padding: EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 12),
                                    child: Text(
                                        watchListAdded
                                            ? I18n.of(context).watchlist_added
                                            : I18n.of(context).add_to_watchlist,
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelLarge
                                            ?.copyWith(
                                                color: watchListAdded
                                                    ? Colors.black
                                                    : Colors.white)),
                                  ),
                                ),
                                SizedBox(
                                  height: 12,
                                ),
                                if (caption != null)
                                  Container(
                                    alignment: Alignment.center,
                                    margin:
                                        EdgeInsets.only(left: 16, right: 16),
                                    child: Text(caption,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge),
                                  ),
                                SizedBox(
                                  height: 12,
                                ),
                              ],
                            ),
                          ),
                          if (illusts.isNotEmpty)
                            SliverPadding(
                              padding: EdgeInsets.only(left: 16, right: 16),
                              sliver: SliverWaterfallFlow.count(
                                crossAxisCount: 2,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                children: [
                                  for (var illust in illusts)
                                    _buildItem(illust),
                                ],
                              ),
                            ),
                        ],
                      );
                    }),
      ),
    );
  }

  Widget _buildItem(IllustStore illust) {
    return IllustSeriesItem(illust: illust);
  }

  Widget _buildErrorContent(BuildContext context, String errorMessage) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child:
                Text(':(', style: Theme.of(context).textTheme.headlineMedium),
          ),
          Text(
            errorMessage,
            maxLines: 5,
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(illustSeriesStoreProvider(widget.id).notifier).fetch();
            },
            child: Text(I18n.of(context).refresh),
          )
        ],
      ),
    );
  }
}

class IllustSeriesItem extends StatefulHookConsumerWidget {
  final IllustStore illust;
  const IllustSeriesItem({super.key, required this.illust});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _State();
}

class _State extends ConsumerState<IllustSeriesItem> {
  late IllustStore illustStore = widget.illust;
  late Illusts illust = illustStore.illusts!;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Leader.push(
            context,
            IllustLightingPage(
                id: illust.id,
                store: IllustStore(illust.id, illust),
                heroString: "illust_series_${illust.id}"));
      },
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                NullHero(
                  tag: "illust_series_${illust.id}",
                  child: PixivImage(
                    illust.imageUrls.large,
                    fit: BoxFit.fitWidth,
                    width: double.infinity,
                  ),
                ),
                if (illust.metaPages.isNotEmpty)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius:
                                BorderRadius.all(Radius.circular(4.0))),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 2.0, horizontal: 2.0),
                          child: Text(
                            illust.metaPages.length.toString(),
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  )
              ],
            ),
          ),
          SizedBox(
            height: 2,
          ),
          Container(
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Expanded(
                      child: Text(
                    illust.title,
                    style: Theme.of(context).textTheme.bodyMedium,
                  )),
                  GestureDetector(
                    onTap: () async {
                      illustStore.star(
                          restrict: userSetting.defaultPrivateLike
                              ? "private"
                              : "public");
                    },
                    child: Observer(builder: (context) {
                      return StarIcon(
                        state: illustStore.state,
                      );
                    }),
                  ),
                ],
              ))
        ],
      ),
    );
  }
}
