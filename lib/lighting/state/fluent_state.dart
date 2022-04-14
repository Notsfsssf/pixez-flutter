import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/component/fluent/fluent_utils.dart';
import 'package:pixez/exts.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/lighting/lighting_page.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

class FluentLightingListState extends LightingListStateBase {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: <Widget>[
          Observer(builder: (_) {
            return Container(child: _buildContent(context));
          }),
          Align(
            child: Visibility(
              visible: backToTopVisible,
              child: Opacity(
                opacity: 0.5,
                child: Container(
                  height: 50.0,
                  width: 50.0,
                  margin: EdgeInsets.only(bottom: 8.0),
                  child: IconButton(
                    icon: Icon(
                      FluentIcons.arrow_up_right, // arrow_drop_up_outlined
                      size: 24,
                    ),
                    onPressed: () {
                      refreshController.position?.jumpTo(0);
                    },
                  ),
                ),
              ),
            ),
            alignment: Alignment.bottomCenter,
          )
        ],
      ),
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

  Widget _buildWithoutHeader(context) {
    store.iStores.removeWhere((element) => element.illusts!.hateByUser());
    return NotificationListener<ScrollNotification>(
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
          enablePullDown: true,
          enablePullUp: true,
          header: buildCustomHeader(),
          footer: _buildCustomFooter(),
          controller: refreshController,
          onRefresh: () {
            store.fetch(force: true);
          },
          onLoading: () {
            store.fetchNext();
          },
          child: WaterfallFlow.builder(
            padding: EdgeInsets.all(5.0),
            itemCount: store.iStores.length,
            itemBuilder: (context, index) {
              return buildItem(index);
            },
            gridDelegate: buildGridDelegate(),
          ),
        ));
  }

  Widget _buildContent(context) {
    return store.errorMessage != null
        ? Container(
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
                  child: Text(':(',
                      style: FluentTheme.of(context).typography.body),
                ),
                TextButton(
                    onPressed: () {
                      store.fetch(force: true);
                    },
                    child: Text(I18n.of(context).retry)),
                Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      (store.errorMessage?.contains("400") == true
                          ? '${I18n.of(context).error_400_hint}\n ${store.errorMessage}'
                          : '${store.errorMessage}'),
                    ))
              ],
            ),
          )
        : store.iStores.isNotEmpty
            ? (widget.header != null
                ? _buildWithHeader(context)
                : _buildWithoutHeader(context))
            : Container();
  }

  Widget _buildWithHeader(BuildContext context) {
    return NotificationListener<ScrollNotification>(
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
        enablePullDown: true,
        enablePullUp: true,
        header: buildCustomHeader(),
        footer: _buildCustomFooter(),
        controller: refreshController,
        onRefresh: () {
          store.fetch(force: true);
        },
        onLoading: () {
          store.fetchNext();
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Container(child: widget.header),
            ),
            SliverWaterfallFlow(
              gridDelegate: buildGridDelegate(),
              delegate: buildSliverChildBuilderDelegate(context),
            )
          ],
        ),
      ),
    );
  }
}
