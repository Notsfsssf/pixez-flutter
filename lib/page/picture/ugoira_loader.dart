import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/component/ugoira_painter.dart';
import 'package:pixez/generated/l10n.dart';
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

  bool isEncoding = false;
   static const platform = const MethodChannel('samples.flutter.dev/battery');
  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      if (_store.status == UgoiraStatus.play) {
        return InkWell(
          onLongPress: () async {
            if (isEncoding) return;
            final result = await showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('${I18n.of(context).Encode}?'),
                    content: Text(I18n.of(context).Encode_Message),
                    actions: <Widget>[
                      FlatButton(
                        child: Text("OK"),
                        onPressed: () {
                          Navigator.of(context).pop("OK");
                        },
                      ),
                      FlatButton(
                        child: Text("CANCEL"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      )
                    ],
                  );
                });
            if (result == "OK") {
              try {
                isEncoding = true;
                platform.invokeMethod('getBatteryLevel', {
                  "path":_store.drawPool.first.parent.path,
                  "delay":  _store
                  .ugoiraMetadataResponse.ugoiraMetadata.frames.first.delay,
                  "name": widget.id.toString()
                });
                BotToast.showCustomText(
                    toastBuilder: (_) => Text("encoding..."));
              } on PlatformException catch (e) {
                isEncoding = false;
              }
            }
          },
          child: UgoiraWidget(
              delay: _store
                  .ugoiraMetadataResponse.ugoiraMetadata.frames.first.delay,
              size: Size(
                  MediaQuery.of(context).size.width.toDouble(),
                  (widget.illusts.height.toDouble() /
                          widget.illusts.width.toDouble()) *
                      MediaQuery.of(context).size.width.toDouble()),
              drawPools: _store.drawPool),
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
