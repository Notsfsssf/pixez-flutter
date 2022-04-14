import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/component/painer_card.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/page/hello/recom/recom_user_page.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class FluentRecomUserPageState extends RecomUserPageStateBase {
  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      return ScaffoldPage(
        header: PageHeader(title: Text(I18n.of(context).recommend_for_you)),
        content: SmartRefresher(
          header: Platform.isAndroid
              ? MaterialClassicHeader(
                  color: FluentTheme.of(context).accentColor,
                )
              : ClassicHeader(),
          controller: refreshController,
          enablePullDown: true,
          enablePullUp: true,
          onRefresh: () => recomUserStore.fetch(),
          onLoading: () => recomUserStore.next(),
          footer: CustomFooter(
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
          ),
          child: recomUserStore.users.isNotEmpty
              ? ListView.builder(
                  itemCount: recomUserStore.users.length,
                  itemBuilder: (context, index) {
                    final data = recomUserStore.users[index];
                    return PainterCard(
                      user: data,
                    );
                  })
              : Container(),
        ),
      );
    });
  }
}
