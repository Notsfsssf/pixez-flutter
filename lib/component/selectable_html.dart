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

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:pixez/generated/l10n.dart';
import 'package:pixez/main.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

class SelectableHtml extends StatefulWidget {
  final String data;

  const SelectableHtml({Key key, @required this.data}) : super(key: key);

  @override
  _SelectableHtmlState createState() => _SelectableHtmlState();
}

class _SelectableHtmlState extends State<SelectableHtml> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: () async {
        await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text("长按复制"),
                content: SelectableText(widget.data ?? ""),
                actions: <Widget>[
                  FlatButton(
                    child: Text(I18n.of(context).ok),
                    onPressed: () {
                      Navigator.of(context).pop("OK");
                    },
                  )
                ],
              );
            });
      },
      child: HtmlWidget(
        widget.data ?? '~',
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
          if (await canLaunch(url)) {
            await launch(url);
          } else {
            Share.share(url);
          }
        },
      ),
    );
  }
}
