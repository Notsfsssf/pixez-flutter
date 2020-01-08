import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixez/component/painter_avatar.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/page/soup/bloc.dart';

class SoupPage extends StatefulWidget {
  final String url;

  SoupPage({Key key, this.url}) : super(key: key);

  @override
  _SoupPageState createState() => _SoupPageState();
}

class _SoupPageState extends State<SoupPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: BlocProvider<SoupBloc>(
        child: BlocBuilder<SoupBloc, SoupState>(builder: (context, snapshot) {
          if (snapshot is DataSoupState) {
            print(snapshot.description);
            return ListView.builder(
              itemBuilder: (BuildContext context, int index) {
                AmWork amWork = snapshot.amWorks[index];
                return Card(
                  child: Column(
                    children: <Widget>[
                      PixivImage(amWork.showImage),
                      ListTile(
                        leading: PainterAvatar(
                          url: amWork.userImage,
                        ),
                        title: Text(amWork.title),
                        subtitle: Text(amWork.user),
                      )
                    ],
                  ),
                );
              },
              itemCount: snapshot.amWorks.length,
            );
          }
          return Container();
        }),
        create: (BuildContext context) =>
            SoupBloc()..add(FetchSoupEvent(widget.url)),
      ),
    );
  }
}
