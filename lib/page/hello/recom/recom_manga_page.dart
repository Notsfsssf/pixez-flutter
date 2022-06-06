import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/lighting/lighting_page.dart';
import 'package:pixez/lighting/lighting_store.dart';
import 'package:pixez/models/illust.dart';
import 'package:pixez/models/recommend.dart';
import 'package:pixez/network/api_client.dart';
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
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: SmartRefresher(
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
                      child: PixivImage(illust!.imageUrls.medium),
                    );
                  },
                  itemCount: _store.iStores.length,
                ),
        ),
      ),
    );
  }
}
