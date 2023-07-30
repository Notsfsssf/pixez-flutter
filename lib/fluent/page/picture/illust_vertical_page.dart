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

import 'package:easy_refresh/easy_refresh.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:pixez/models/illust.dart';
import 'package:pixez/fluent/page/picture/illust_items_page.dart';

class IllustVerticalPage extends IllustItemsPage {
  const IllustVerticalPage(
      {Key? key, required super.id, super.heroString, super.store})
      : super(key: key);

  @override
  _IllustVerticalPageState createState() => _IllustVerticalPageState();
}

class _IllustVerticalPageState extends IllustItemsPageState {
  @override
  Widget buildContent(BuildContext context, Illusts? data) {
    if (illustStore.errorMessage != null) return buildErrorContent(context);
    if (data == null)
      return Container(
        child: Center(
          child: ProgressRing(),
        ),
      );
    return LayoutBuilder(
      builder: (context, constraints) {
        final height =
            ((data.height.toDouble() / data.width) * constraints.maxWidth);
        return EasyRefresh(
          controller: refreshController,
          onLoad: () {
            aboutStore.next();
          },
          child: CustomScrollView(
            controller: scrollController,
            slivers: [
              ...buildPhotoList(data, false, height),
              ...buildDetail(context, data)
            ],
          ),
        );
      },
    );
  }
}
