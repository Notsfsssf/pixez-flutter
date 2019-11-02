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
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/models/illust.dart';
import 'package:pixez/fluent/page/picture/illust_items_page.dart';

class IllustRowPage extends IllustItemsPage {
  const IllustRowPage(
      {Key? key, required super.id, super.heroString, super.store})
      : super(key: key);

  @override
  _IllustRowPageState createState() => _IllustRowPageState();
}

class _IllustRowPageState extends IllustItemsPageState {
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
        final expectWidth = constraints.maxWidth - 300;
        final radio = (data.height.toDouble() / data.width);
        final screenHeight = constraints.maxHeight;
        final height = (radio * expectWidth);
        final centerType = height <= screenHeight;

        return Container(
          child: Row(
            children: [
              Container(
                width: expectWidth,
                child: CustomScrollView(
                    slivers: [...buildPhotoList(data, centerType, height)]),
              ),
              Expanded(
                child: Container(
                  color: FluentTheme.of(context).cardColor,
                  margin: EdgeInsets.only(right: 4.0),
                  child: EasyRefresh(
                    controller: refreshController,
                    onLoad: () {
                      aboutStore.next();
                    },
                    child: Observer(
                      builder: (_) => CustomScrollView(
                        controller: scrollController,
                        slivers: [
                          ...buildDetail(context, data),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
