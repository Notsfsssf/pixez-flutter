import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/novel/component/novel_bookmark_button.dart';
import 'package:pixez/page/novel/recom/bloc.dart';
import 'package:pixez/page/novel/viewer/novel_viewer.dart';

class NovelRecomPage extends StatefulWidget {
  @override
  _NovelRecomPageState createState() => _NovelRecomPageState();
}

class _NovelRecomPageState extends State<NovelRecomPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<NovelRecomBloc>(
      child: BlocBuilder<NovelRecomBloc, NovelRecomState>(
          builder: (context, state) {
        return EasyRefresh(
          firstRefresh: true,
          onRefresh: () {
            BlocProvider.of<NovelRecomBloc>(context)
                .add(FetchNovelRecomEvent());
            return;
          },
          onLoad: (){

          },
          child: state is DataNovelRecomState
              ? ListView.builder(
                  itemCount: state.novels.length,
                  itemBuilder: (context, index) {
                    var novel = state.novels[index];
                    return ListTile(
                      title: Text(novel.title),
                      subtitle: Text(novel.user.name,maxLines: 1,),
                      onTap: () {
                        Navigator.of(context, rootNavigator: true).push(
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    NovelViewerPage(
                                     id: novel.id,
                                      novel: novel,
                                    )));
                      },
                      trailing: NovelBookmarkButton(
                        novel:novel
                      ),
                    );
                  })
              : Container(),
        );
      }),
      create: (BuildContext context) =>
          NovelRecomBloc(RepositoryProvider.of<ApiClient>(context)),
    );
  }
}
