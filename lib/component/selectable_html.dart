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

import 'dart:io';

import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:pixez/component/text_selection_toolbar.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/exts.dart';
import 'package:pixez/main.dart';
import 'package:pixez/supportor_plugin.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

class SelectableHtml extends StatefulWidget {
  final String data;

  const SelectableHtml({Key? key, required this.data}) : super(key: key);

  @override
  _SelectableHtmlState createState() => _SelectableHtmlState();
}

class _SelectableHtmlState extends State<SelectableHtml> {
  bool l = false;

  @override
  void initState() {
    super.initState();

    initMethod();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: () async {
        setState(() {
          l = true;
        });
      },
      child: l
          ? Container(
              child: Column(
                children: [
                  (Platform.isAndroid)
                      ? ExtendedText(
                          (widget.data).toTranslateText(),
                          style: Theme.of(context).textTheme.bodyText1,
                          selectionEnabled: true,
                          textSelectionControls:
                              TranslateTextSelectionControls(),
                        )
                      : ExtendedText(
                          (widget.data).toTranslateText(),
                          style: Theme.of(context).textTheme.bodyText1,
                          selectionEnabled: true,
                        ),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (supportTranslate)
                        InkWell(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Icon(Icons.translate),
                          ),
                          onTap: () {
                            SupportorPlugin.start(
                                (widget.data).toTranslateText());
                          },
                        ),
                      InkWell(
                          child: Icon(Icons.close),
                          onTap: () {
                            setState(() {
                              l = false;
                            });
                          })
                    ],
                  )
                ],
              ),
            )
          : HtmlWidget(
              widget.data,
              customStylesBuilder: (e) {
                if (e.attributes.containsKey('href')) {
                  final color = userSetting.themeData.accentColor;
                  return {
                    'color': '#${color.value.toRadixString(16).substring(2, 8)}'
                  };
                }
                return null;
              },
              onTapUrl: (String url) async {
                try {
                  if (url.startsWith("pixiv")) {
                    Leader.pushWithUri(context, Uri.parse(url));
                  }
                  await launch(url);
                } catch (e) {
                  Share.share(url);
                }
              },
            ),
    );
  }

  bool supportTranslate = false;

  Future<void> initMethod() async {
    if (!Platform.isAndroid) return;
    bool results = await SupportorPlugin.processText();
    setState(() {
      supportTranslate = results;
    });
  }
}
