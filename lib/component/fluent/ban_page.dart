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

import 'package:fluent_ui/fluent_ui.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/page/fluent/shield/shield_page.dart';

class BanPage extends StatefulWidget {
  final String name;
  final VoidCallback? onPressed;

  const BanPage({Key? key, required this.name, this.onPressed})
      : super(key: key);

  @override
  _BanPageState createState() => _BanPageState();
}

class _BanPageState extends State<BanPage> {
  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      content: Center(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'X_X',
                style: TextStyle(fontSize: 26),
              ),
            ),
            Text(
              I18n.of(context).shield_message(widget.name),
              textAlign: TextAlign.center,
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 8.0,
              ),
              child: FilledButton(
                child: Text(I18n.of(context).shielding_settings),
                onPressed: () {
                  Leader.push(context, ShieldPage());
                },
              ),
            ),
            HyperlinkButton(
                onPressed: () {
                  if (widget.onPressed != null) widget.onPressed!();
                },
                child: Text(I18n.of(context).temporarily_visible)),
          ],
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
        ),
      ),
    );
  }
}
