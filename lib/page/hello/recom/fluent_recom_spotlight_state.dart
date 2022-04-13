import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/component/illust_card.dart';
import 'package:pixez/component/spotlight_card.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/exts.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/page/hello/recom/recom_spotlight_page.dart';
import 'package:pixez/page/hello/recom/recom_user_road.dart';
import 'package:pixez/page/spotlight/spotlight_page.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

class FluentRecomSpolightPageState extends RecomSpolightPageStateBase {
  bool backToTopVisible = false;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return buildPage(context);
  }

  Widget buildPage(BuildContext context) {
    return ScaffoldPage(
      header: PageHeader(
        title: Text(
          I18n.of(context).spotlight,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24.0,
              color: FluentTheme.of(context).typography.subtitle?.color),
        ),
        commandBar: CommandBar(
          overflowBehavior: CommandBarOverflowBehavior.noWrap,
          primaryItems: [
            CommandBarButton(
              icon: Icon(FluentIcons.refresh),
              label: Text("Refresh"),
              onPressed: () async {
                await fetchT();
              },
            ),
            CommandBarButton(
              icon: Icon(FluentIcons.more),
              label: Text(I18n.of(context).more),
              onPressed: () async {
                Leader.dialog(context, SpotLightPage());
              },
            ),
          ],
        ),
      ),
      content: SafeArea(
        child: Observer(builder: (context) {
          return Stack(
            children: [
              NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification notification) {
                  ScrollMetrics metrics = notification.metrics;
                  if (backToTopVisible == metrics.atEdge && mounted) {
                    setState(() {
                      backToTopVisible = !backToTopVisible;
                    });
                  }
                  return true;
                },
                child: SmartRefresher(
                  controller: easyRefreshController,
                  enablePullDown: true,
                  enablePullUp: true,
                  footer: _buildCustomFooter(),
                  header: _buildCustomHeader(),
                  onRefresh: () async {
                    await fetchT();
                  },
                  onLoading: () async {
                    await lightingStore.fetchNext();
                  },
                  child: _buildWaterFall(),
                ),
              ),
              Align(
                child: Visibility(
                  visible: backToTopVisible,
                  child: Opacity(
                    opacity: 0.5,
                    child: Container(
                      height: 24.0,
                      margin: EdgeInsets.only(bottom: 8.0),
                      child: IconButton(
                        icon: Icon(
                          FluentIcons.up, //arrow_drop_up_outlined,
                          size: 24,
                        ),
                        onPressed: () {
                          easyRefreshController.position?.jumpTo(0);
                        },
                      ),
                    ),
                  ),
                ),
                alignment: Alignment.bottomCenter,
              )
            ],
          );
        }),
      ),
    );
  }

  CustomHeader _buildCustomHeader() {
    return CustomHeader(
      builder: (context, mode) {
        Widget body;
        if (mode == RefreshStatus.idle) {
          body = Text("refresh");
        } else if (mode == RefreshStatus.refreshing) {
          body = ProgressRing();
        } else if (mode == RefreshStatus.failed) {
          body = Text(I18n.of(context).loading_failed_retry_message);
        } else {
          body = Text("Success");
        }
        return Container(
          height: 55.0,
          child: Center(child: body),
        );
      },
    );
  }

  CustomFooter _buildCustomFooter() {
    return CustomFooter(
      builder: (BuildContext context, LoadStatus? mode) {
        Widget body;
        if (mode == LoadStatus.idle) {
          body = Text(I18n.of(context).pull_up_to_load_more);
        } else if (mode == LoadStatus.loading) {
          body = ProgressRing();
        } else if (mode == LoadStatus.failed) {
          body = Text(I18n.of(context).loading_failed_retry_message);
        } else if (mode == LoadStatus.canLoading) {
          body = Text(I18n.of(context).let_go_and_load_more);
        } else {
          body = Text(I18n.of(context).no_more_data);
        }
        return Container(
          height: 55.0,
          child: Center(child: body),
        );
      },
    );
  }

  Widget _buildWaterFall() {
    lightingStore.iStores
        .removeWhere((element) => element.illusts!.hateByUser());
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _buildSpotlightContainer(),
        ),
        SliverToBoxAdapter(
          child: _buildSecondRow(context, I18n.of(context).recommend_for_you),
        ),
        _buildWaterfall(MediaQuery.of(context).orientation)
      ],
    );
  }

  Widget _buildWaterfall(Orientation orientation) {
    return lightingStore.iStores.isNotEmpty
        ? SliverWaterfallFlow(
            gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              // TODO: 从用户设置中读取列数
              // (orientation == Orientation.portrait)
              //     ? userSetting.crossCount
              //     : userSetting.hCrossCount,
              collectGarbage: (List<int> garbages) {
                // garbages.forEach((index) {
                //   final provider = ExtendedNetworkImageProvider(
                //     lightingStore.iStores[index].illusts!.imageUrls.medium,
                //   );
                //   provider.evict();
                // });
              },
            ),
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return IllustCard(
                  store: lightingStore.iStores[index],
                  iStores: lightingStore.iStores,
                );
              },
              childCount: lightingStore.iStores.length,
            ),
          )
        : (lightingStore.errorMessage?.isNotEmpty == true
            ? SliverToBoxAdapter(
                child: Container(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        height: 50,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          ':(',
                          // style: FluentTheme.of(context).textTheme.headline4,
                        ),
                      ),
                      TextButton(
                          onPressed: () {
                            lightingStore.fetch(force: true);
                          },
                          child: Text(I18n.of(context).retry)),
                      Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            (lightingStore.errorMessage?.contains("400") == true
                                ? '${I18n.of(context).error_400_hint}\n ${lightingStore.errorMessage}'
                                : '${lightingStore.errorMessage}'),
                          ))
                    ],
                  ),
                ),
              )
            : SliverToBoxAdapter(
                child: Container(
                  height: 30,
                ),
              ));
  }

  Widget _buildSpotlightContainer() {
    return Container(
      height: 230.0,
      padding: EdgeInsets.only(left: 5.0),
      child: spotlightStore.articles.isNotEmpty
          ? ListView.builder(
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final spotlight = spotlightStore.articles[index];
                return SpotlightCard(
                  spotlight: spotlight,
                );
              },
              itemCount: spotlightStore.articles.length,
              scrollDirection: Axis.horizontal,
            )
          : Container(),
    );
  }

  Widget _buildFirstRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            child: Padding(
              child: Text(
                I18n.of(context).spotlight,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24.0,
                  // color: FluentTheme.of(context).textTheme.headline6!.color,
                ),
              ),
              padding: EdgeInsets.only(left: 20.0, bottom: 10.0),
            ),
          ),
          Padding(
            child: TextButton(
              child: Text(
                I18n.of(context).more,
                // style: FluentTheme.of(context).textTheme.caption,
              ),
              onPressed: () {
                Navigator.of(context)
                    .push(FluentPageRoute(builder: (BuildContext context) {
                  return SpotLightPage();
                }));
              },
            ),
            padding: EdgeInsets.all(8.0),
          )
        ],
      ),
    );
  }

  Widget _buildSecondRow(BuildContext context, String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Padding(
          child: Center(
            child: Text(
              title,
              overflow: TextOverflow.clip,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24.0),
            ),
          ),
          padding: EdgeInsets.only(left: 20.0),
        ),
        Expanded(child: RecomUserRoad())
      ],
    );
  }
}