import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/component/ugoira_animation.dart';
import 'package:pixez/models/illust.dart';
import 'package:pixez/page/picture/bloc/ugoira_metadata_bloc.dart';
import 'package:pixez/page/picture/bloc/ugoira_metadata_event.dart';
import 'package:pixez/page/picture/bloc/ugoira_metadata_state.dart';

class UgoiraPage extends StatefulWidget {
  final Illusts illust;

  const UgoiraPage({Key key, this.illust}) : super(key: key);
  @override
  _UgoiraPageState createState() => _UgoiraPageState();
}

class _UgoiraPageState extends State<UgoiraPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Ugoira"),),
      body: BlocBuilder<UgoiraMetadataBloc, UgoiraMetadataState>(
          builder: (context, snapshot) {
        if (snapshot is DownLoadProgressState) {
          return Center(
            child: CircularProgressIndicator(
              value: snapshot.count / snapshot.total,
            ),
          );
        }
        if (snapshot is PlayUgoiraMetadataState) {
          return UgoiraAnima(   snapshot.listSync,snapshot.frames);
        }
        return Stack(
          children: <Widget>[
            Hero(
              child: PixivImage(
                widget.illust.imageUrls.large,
                placeHolder: widget.illust.imageUrls.medium,
              ),
              tag: widget.illust.imageUrls.medium,
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: IconButton(
                onPressed: () {
                  BlocProvider.of<UgoiraMetadataBloc>(context)
                      .add(FetchUgoiraMetadataEvent(widget.illust.id));
                },
                icon: Icon(Icons.play_arrow),
              ),
            )
          ],
        );
      }),
    );
  }
}
