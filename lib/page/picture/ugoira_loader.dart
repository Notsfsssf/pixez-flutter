import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/component/ugoira_painter.dart';
import 'package:pixez/models/illust.dart';
import 'package:pixez/page/picture/ugoira_store.dart';

class UgoiraLoader extends StatefulWidget {
  final int id;
  final Illusts illusts;
  const UgoiraLoader({Key key, @required this.id, @required this.illusts})
      : super(key: key);
  @override
  _UgoiraLoaderState createState() => _UgoiraLoaderState();
}

class _UgoiraLoaderState extends State<UgoiraLoader> {
  UgoiraStore _store;
  @override
  void initState() {
    _store = UgoiraStore(widget.id);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      if (_store.status == UgoiraStatus.play) {
        return Column(
          children: <Widget>[
            UgoiraWidget(
                delay: _store
                    .ugoiraMetadataResponse.ugoiraMetadata.frames.first.delay,
                size: Size(
                    MediaQuery.of(context).size.width.toDouble(),
                    (widget.illusts.height.toDouble() /
                            widget.illusts.width.toDouble()) *
                        MediaQuery.of(context).size.width.toDouble()),
                drawPools: _store.drawPool),
            LinearProgressIndicator(
              backgroundColor: Theme.of(context).cardColor,
              valueColor:
                  AlwaysStoppedAnimation<Color>(Theme.of(context).accentColor),
              value: 1,
            )
          ],
        );
      }
      if (_store.status == UgoiraStatus.progress)
        return Column(
          children: <Widget>[
            PixivImage(widget.illusts.imageUrls.medium),
            LinearProgressIndicator(
              backgroundColor: Theme.of(context).cardColor,
              valueColor:
                  AlwaysStoppedAnimation<Color>(Theme.of(context).accentColor),
              value: _store.count / _store.total,
            )
          ],
        );
      return Column(
        children: <Widget>[
          PixivImage(widget.illusts.imageUrls.medium),
          Center(
            child: IconButton(
                icon: Icon(Icons.play_arrow),
                onPressed: () {
                  _store.downloadAndUnzip();
                }),
          )
        ],
      );
    });
  }
}
