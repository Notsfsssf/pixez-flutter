import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/lighting/lighting_page.dart';
import 'package:pixez/lighting/lighting_store.dart';
import 'package:pixez/models/illust.dart';
import 'package:pixez/models/recommend.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/picture/illust_lighting_page.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class RecomMangaPage extends StatefulWidget {
  const RecomMangaPage({Key? key}) : super(key: key);

  @override
  State<RecomMangaPage> createState() => _RecomMangaPageState();
}

class _RecomMangaPageState extends State<RecomMangaPage> {
  RefreshController controller = RefreshController();
  late LightingStore _store;

  @override
  void initState() {
    _store = LightingStore(
      ApiSource(
        futureGet: () => apiClient.getMangaRecommend(),
      ),
      controller,
    );
    _store.fetch();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manga"),
      ),
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Observer(builder: (_) {
        return SmartRefresher(
          controller: controller,
          onLoading: () {
            _store.fetchNext();
          },
          onRefresh: () {
            _store.fetch();
          },
          enablePullDown: true,
          enablePullUp: true,
          child: Container(
            child: _store.iStores.isEmpty
                ? Container()
                : ListView.builder(
                    itemBuilder: (context, index) {
                      final illust = _store.iStores[index].illusts;
                      return Card(
                        child: InkWell(
                            onTap: () {
                              Leader.push(
                                  context, IllustLightingPage(id: illust!.id));
                            },
                            child: PixivImage(illust!.imageUrls.medium)),
                      );
                    },
                    itemCount: _store.iStores.length,
                  ),
          ),
        );
      }),
    );
  }
}
