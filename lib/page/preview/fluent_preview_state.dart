import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/component/fluent/fluent_utils.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/component/fluent/fluent_ink_well.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/page/login/login_page.dart';
import 'package:pixez/page/preview/preview_page.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

class FluentPreviewPageState extends PreviewPageStateBase {
  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      return ScaffoldPage(
        header: PageHeader(
          title: Text('Preview'),
          commandBar: CommandBar(
            overflowBehavior: CommandBarOverflowBehavior.noWrap,
            primaryItems: [
              CommandBarButton(
                icon: Icon(FluentIcons.signin),
                label: Text("Login"),
                onPressed: () {
                  Leader.dialog(context, LoginPage());
                },
              ),
              CommandBarButton(
                icon: Icon(FluentIcons.refresh),
                label: Text("Refresh"),
                onPressed: () => lightingStore.fetch(url: "walkthrough"),
              ),
            ],
          ),
        ),
        content: SafeArea(
          child: SmartRefresher(
            controller: easyRefreshController,
            onRefresh: () => lightingStore.fetch(url: "walkthrough"),
            onLoading: () => lightingStore.fetchNext(),
            header: buildCustomHeader(),
            child: lightingStore.iStores.isNotEmpty
                ? WaterfallFlow.builder(
                    shrinkWrap: true,
                    gridDelegate:
                        SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                    ),
                    itemBuilder: _buildItem,
                    itemCount: lightingStore.iStores.length,
                  )
                : Container(),
          ),
        ),
      );
    });
  }

  Widget _buildItem(BuildContext context, int index) {
    return InkWell(
      child: Tooltip(
        useMousePosition: true,
        message: '\nTitle: ${lightingStore.iStores[index].illusts!.title}\n' +
            'Author: ${lightingStore.iStores[index].illusts!.user}\n' +
            'Page Count: ${lightingStore.iStores[index].illusts!.pageCount}\n',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PixivImage(
              lightingStore.iStores[index].illusts!.imageUrls.medium,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(lightingStore.iStores[index].illusts!.title),
                Text(lightingStore.iStores[index].illusts!.user.name),
              ],
            ),
          ],
        ),
      ),
      onTap: () {
        Leader.fluentNav(
            context,
            Icon(FluentIcons.image_pixel),
            Text("图片预览 ${lightingStore.iStores[index].illusts?.id}"),
            GoToLoginPage(illust: lightingStore.iStores[index].illusts!));
      },
    );
  }
}
