import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:pixez/component/painter_avatar.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/models/spotlight_response.dart';
import 'package:pixez/page/picture/picture_page.dart';
import 'package:pixez/page/soup/bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class SoupPage extends StatefulWidget {
  final String url;
  final SpotlightArticle spotlight;
  SoupPage({Key key, this.url, this.spotlight}) : super(key: key);

  @override
  _SoupPageState createState() => _SoupPageState();
}

class _SoupPageState extends State<SoupPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<SoupBloc>(
      create: (BuildContext context) =>
          SoupBloc()..add(FetchSoupEvent(widget.url)),
      child: BlocBuilder<SoupBloc, SoupState>(builder: (context, snapshot) {
        return Scaffold(
          body: NestedScrollView(
            body: buildBlocProvider(snapshot),
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  pinned: true,
                  expandedHeight: 200.0,
                  flexibleSpace: FlexibleSpaceBar(
                      centerTitle: true,
                      title: Text(widget.spotlight.pureTitle),
                      background: PixivImage(widget.spotlight.thumbnail)),
                  actions: <Widget>[
                    IconButton(
                      icon: Icon(Icons.share),
                      onPressed: () async {
                        var url = widget.spotlight.articleUrl;
                        if (await canLaunch(url)) {
                          await launch(url);
                        } else {}
                      },
                    )
                  ],
                )
              ];
            },
          ),
        );
      }),
    );
  }

  Widget buildBlocProvider(snapshot) {
    if (snapshot is DataSoupState) {
      print(snapshot.description);
      return ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          if (index == 0)
            return Card(
              child: Text(snapshot.description),
            );
          AmWork amWork = snapshot.amWorks[index - 1];
          return InkWell(
            onTap: () {
              Navigator.of(context,rootNavigator: true)
                  .push(MaterialPageRoute(builder: (BuildContext context) {
                return PicturePage(
                    null,
                    int.parse(amWork.arworkLink
                        .replaceAll('https://www.pixiv.net/artworks/', '')));
              }));
            },
            child: Card(
              clipBehavior: Clip.antiAlias,
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8.0))),
              child: Column(
                children: <Widget>[
                  ListTile(
                    leading: PainterAvatar(
                      url: amWork.userImage,
                      id: int.parse(amWork.userLink
                          .replaceAll('https://www.pixiv.net/users/', '')),
                    ),
                    title: Text(amWork.title),
                    subtitle: Text(amWork.user),
                  ),
                  PixivImage(amWork.showImage),
                ],
              ),
            ),
          );
        },
        itemCount: snapshot.amWorks.length + 1,
      );
    }
    return Container();
  }
}
