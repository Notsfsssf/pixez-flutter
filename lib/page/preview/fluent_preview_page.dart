import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/component/fluent_pixiv_image.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/lighting/lighting_store.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/login/fluent_login_page.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

class FluentPreviewPage extends StatefulWidget {
  @override
  _FluentPreviewPageState createState() => _FluentPreviewPageState();
}

// TODO: 懒加载
class _FluentPreviewPageState extends State<FluentPreviewPage> {
  late LightingStore _lightingStore;
  RefreshController _easyRefreshController =
      RefreshController(initialRefresh: true);

  @override
  void initState() {
    _lightingStore = LightingStore(
      ApiSource(futureGet: () => apiClient.walkthroughIllusts()),
      _easyRefreshController,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      return SafeArea(
        child: ScaffoldPage(
          header: PageHeader(
            title: Text('Preview'),
            commandBar: CommandBar(
              overflowBehavior: CommandBarOverflowBehavior.noWrap,
              primaryItems: [
                CommandBarButton(
                  icon: Icon(FluentIcons.signin),
                  label: Text("Login"),
                  onPressed: () {
                    Leader.dialog(context, FluentLoginPage());
                  },
                ),
                CommandBarButton(
                  icon: Icon(FluentIcons.refresh),
                  label: Text("Refresh"),
                  onPressed: () => _lightingStore.fetch(url: "walkthrough"),
                ),
              ],
            ),
          ),
          content: Container(
            alignment: Alignment.center,
            child: SafeArea(
              child: _lightingStore.iStores.isNotEmpty
                  ? WaterfallFlow.builder(
                      shrinkWrap: true,
                      gridDelegate:
                          SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        mainAxisSpacing: 8.0,
                        crossAxisSpacing: 8.0,
                      ),
                      itemBuilder: _getImageItem,
                      itemCount: _lightingStore.iStores.length,
                    )
                  : ProgressRing(),
            ),
          ),
        ),
      );
    });
  }

  Widget _getImageItem(BuildContext context, int index) {
    return HoverButton(
      builder: (context, state) {
        return Card(
          backgroundColor: Colors.transparent,
          padding: const EdgeInsets.all(0.0),
          child: FocusBorder(
            focused: state.isFocused,
            child: Tooltip(
              useMousePosition: true,
              message: '\nTitle: ${_lightingStore.iStores[index].illusts!.title}\n' +
                  'Author: ${_lightingStore.iStores[index].illusts!.user}\n' +
                  'Page Count: ${_lightingStore.iStores[index].illusts!.pageCount}\n',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FluentPixivImage(
                    _lightingStore.iStores[index].illusts!.imageUrls.medium,
                  ),
                  Acrylic(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(_lightingStore.iStores[index].illusts!.title),
                        Text(_lightingStore.iStores[index].illusts!.user.name),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      onTapUp: () {
        // Navigator.of(context).push(FluentPageRoute(
        //     builder: (BuildContext context) =>
        //         GoToLoginPage(illust: _lightingStore.iStores[index].illusts!)));
      },
    );
  }

  @override
  void dispose() {
    _easyRefreshController.dispose();
    super.dispose();
  }
}
