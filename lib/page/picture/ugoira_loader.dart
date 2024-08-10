/*
 * Copyright (C) 2020. by perol_notsf, All rights reserved
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program. If not, see <http://www.gnu.org/licenses/>.
 *
 */

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/component/ugoira_painter.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/illust.dart';
import 'package:pixez/page/picture/ugoira_store.dart';

class UgoiraLoader extends StatefulWidget {
  final int id;
  final Illusts illusts;

  const UgoiraLoader({Key? key, required this.id, required this.illusts})
      : super(key: key);

  @override
  _UgoiraLoaderState createState() => _UgoiraLoaderState();
}

class _UgoiraLoaderState extends State<UgoiraLoader> {
  late UgoiraStore _store;

  @override
  void initState() {
    _store = UgoiraStore(widget.id);
    super.initState();
  }

  bool isEncoding = false;
  static const platform = const MethodChannel('samples.flutter.dev/battery');

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final maxWidth = constraints.maxWidth;
      return Observer(builder: (_) {
        double height = maxWidth *
            (widget.illusts.height.toDouble() /
                widget.illusts.width.toDouble());
        if (_store.status == UgoiraStatus.play) {
          return InkWell(
            onLongPress: () async {
              if (isEncoding) return;
              final result = await showModalBottomSheet(
                  context: context,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  builder: (context) {
                    return SafeArea(
                        child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          title: Text(I18n.of(context).encode_message),
                        ),
                        ListTile(
                          title: Text(I18n.of(context).encode),
                          onTap: () {
                            Navigator.of(context).pop('OK');
                          },
                        ),
                        ListTile(
                          title: Text(I18n.of(context).export),
                          onTap: () {
                            Navigator.of(context).pop('EXPORT');
                          },
                        ),
                        ListTile(
                          title: Text(I18n.of(context).cancel),
                          onTap: () {
                            Navigator.of(context).pop('SOURCE');
                          },
                        ),
                      ],
                    ));
                  });
              if (result == "OK") {
                try {
                  isEncoding = true;
                  platform.invokeMethod('getBatteryLevel', {
                    "path": _store.drawPool.first.parent.path,
                    "delay": _store.ugoiraMetadataResponse!.ugoiraMetadata
                        .frames.first.delay,
                    "delay_array": _store
                        .ugoiraMetadataResponse!.ugoiraMetadata.frames
                        .map((e) => e.delay)
                        .toList(),
                    "name": userSetting.singleFolder
                        ? "${widget.illusts.user.name}_${widget.illusts.user.id}/${widget.id}"
                        : "${widget.id}",
                  });
                  BotToast.showCustomText(
                      toastBuilder: (_) => Text("encoding..."));
                } on PlatformException {
                  isEncoding = false;
                }
              } else if (result == "SOURCE") {
              } else if (result == "EXPORT") {
                _store.export();
              }
            },
            child: UgoiraWidget(
                delay: _store
                    .ugoiraMetadataResponse!.ugoiraMetadata.frames.first.delay,
                ugoiraMetadataResponse: _store.ugoiraMetadataResponse!,
                size: Size(
                    maxWidth,
                    (widget.illusts.height.toDouble() /
                            widget.illusts.width.toDouble()) *
                        maxWidth),
                drawPools: _store.drawPool),
          );
        }
        if (_store.status == UgoiraStatus.progress)
          return Column(
            children: <Widget>[
              PixivImage(
                widget.illusts.imageUrls.medium,
                height: height,
                width: maxWidth,
                placeWidget: Container(
                  height: height,
                ),
              ),
              LinearProgressIndicator(
                backgroundColor: Theme.of(context).cardColor,
                valueColor: AlwaysStoppedAnimation(
                    Theme.of(context).colorScheme.secondary),
                value: _store.count / _store.total,
              )
            ],
          );
        return Container(
          height: height + 72.0,
          child: Stack(
            children: <Widget>[
              PixivImage(
                widget.illusts.imageUrls.medium,
                height: height,
                width: maxWidth,
                placeWidget: Container(
                  height: height,
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: GestureDetector(
                  onTap: () {
                    _store.downloadAndUnzip();
                  },
                  child: Container(
                    height: 72.0,
                    width: 72.0,
                    child: Icon(Icons.play_arrow),
                  ),
                ),
              )
            ],
          ),
        );
      });
    });
  }
}
