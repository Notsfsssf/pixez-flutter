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
import 'package:fluent_ui/fluent_ui.dart' hide Image;
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/component/fluent/context_menu.dart';
import 'package:pixez/component/fluent/pixiv_image.dart';
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
      final width = constraints.maxWidth;
      return Observer(builder: (_) {
        double height = widget.illusts.height.toDouble() /
            widget.illusts.width.toDouble() *
            width;
        if (_store.status == UgoiraStatus.play) {
          return ContextMenu(
            child: UgoiraWidget(
              delay: _store
                  .ugoiraMetadataResponse!.ugoiraMetadata.frames.first.delay,
              ugoiraMetadataResponse: _store.ugoiraMetadataResponse!,
              size: Size(width, height),
              drawPools: _store.drawPool,
            ),
            items: [
              MenuFlyoutItem(
                text: Text(I18n.of(context).encode_message),
                onPressed: () {},
              ),
              MenuFlyoutSeparator(),
              MenuFlyoutItem(
                text: Text(I18n.of(context).encode),
                onPressed: () async {
                  try {
                    isEncoding = true;
                    await platform.invokeMethod('getBatteryLevel', {
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
                  Navigator.of(context).pop();
                },
              ),
              MenuFlyoutItem(
                text: Text(I18n.of(context).export),
                onPressed: () async {
                  await _store.export();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        }
        if (_store.status == UgoiraStatus.progress)
          return Column(
            children: <Widget>[
              PixivImage(widget.illusts.imageUrls.medium),
              ProgressBar(value: _store.count / _store.total)
            ],
          );
        return Container(
          height: height + 72.0,
          child: Stack(
            children: <Widget>[
              PixivImage(
                widget.illusts.imageUrls.medium,
                height: height,
                width: width,
                placeWidget: Container(
                  height: height,
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 72.0,
                  width: 72.0,
                  child: IconButton(
                      icon: Icon(FluentIcons.play),
                      onPressed: () {
                        _store.downloadAndUnzip();
                      }),
                ),
              )
            ],
          ),
        );
      });
    });
  }
}
