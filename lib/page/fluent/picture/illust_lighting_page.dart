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
import 'package:pixez/main.dart';
import 'package:pixez/page/fluent/picture/illust_items_page.dart';
import 'package:pixez/page/fluent/picture/illust_row_page.dart';
import 'package:pixez/page/fluent/picture/illust_vertical_page.dart';

class IllustLightingPage extends IllustItemsPage {
  const IllustLightingPage(
      {Key? key, required super.id, super.heroString, super.store})
      : super(key: key);

  @override
  State<IllustLightingPage> createState() => _IllustLightingPageState();
}

class _IllustLightingPageState extends State<IllustLightingPage> {
  @override
  Widget build(BuildContext context) {
    switch (userSetting.padMode) {
      case 0:
        MediaQueryData mediaQuery = MediaQuery.of(context);
        final ori = mediaQuery.size.width > mediaQuery.size.height;
        if (ori)
          return _buildRow();
        else
          return _buildVertical();
      case 1:
        return _buildVertical();
      case 2:
        return _buildRow();
      default:
        return Container();
    }
  }

  _buildVertical() {
    return IllustVerticalPage(
      id: widget.id,
      store: widget.store,
      heroString: widget.heroString,
    );
  }

  _buildRow() {
    return IllustRowPage(
      id: widget.id,
      store: widget.store,
      heroString: widget.heroString,
    );
  }
}
