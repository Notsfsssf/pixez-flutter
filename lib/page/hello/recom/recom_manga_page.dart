import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:pixez/lighting/lighting_page.dart';
import 'package:pixez/lighting/lighting_store.dart';
import 'package:pixez/network/api_client.dart';

class RecomMangaPage extends StatefulWidget {
  const RecomMangaPage({Key? key}) : super(key: key);

  @override
  State<RecomMangaPage> createState() => _RecomMangaPageState();
}

class _RecomMangaPageState extends State<RecomMangaPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Manga")),
      body: LightingList(source: ApiSource(futureGet: () async {
        return await apiClient.getMangaRecommend();
      })),
    );
  }
}
