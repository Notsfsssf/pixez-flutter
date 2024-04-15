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
import 'package:flutter/gestures.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import 'package:pixez/fluent/component/context_menu.dart';
import 'package:pixez/fluent/component/painter_avatar.dart';
import 'package:pixez/fluent/component/selectable_html.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/models/illust.dart';
import 'package:pixez/fluent/page/comment/comment_page.dart';
import 'package:pixez/fluent/page/picture/row_card.dart';
import 'package:pixez/page/picture/illust_detail_store.dart';

class GestureMe extends GestureRecognizer {
  @override
  void acceptGesture(int pointer) {}

  @override
  String get debugDescription => throw UnimplementedError();

  @override
  void rejectGesture(int pointer) {}
}

class IllustDetailBody extends StatelessWidget {
  final Illusts illust;

  IllustDetailBody({Key? key, required this.illust}) : super(key: key);

  Widget colorText(String text, BuildContext context) => Text(
        text,
        style: TextStyle(color: FluentTheme.of(context).accentColor),
      );

  Widget _buildNameAvatar(
      BuildContext context, Illusts illust, IllustDetailStore _store) {
    return ContextMenu(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
              child: Container(
                height: 70,
                width: 70,
                child: Stack(
                  children: <Widget>[
                    Center(
                      child: SizedBox(
                        height: 70,
                        width: 70,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _store.isFollow
                                ? Colors.yellow
                                : FluentTheme.of(context).accentColor,
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: PainterAvatar(
                        url: illust.user.profileImageUrls.medium,
                        id: illust.user.id,
                      ),
                    ),
                  ],
                ),
              ),
              padding: EdgeInsets.all(8.0)),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(
                    illust.title,
                    style:
                        TextStyle(color: FluentTheme.of(context).accentColor),
                  ),
                  Container(
                    height: 4.0,
                  ),
                  Text(
                    illust.user.name,
                    style: FluentTheme.of(context).typography.body,
                  ),
                  Text(
                    toShortTime(illust.createDate),
                    style: FluentTheme.of(context).typography.caption,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      items: [
        MenuFlyoutItem(
          text: Text(I18n.of(context).follow),
          onPressed: () async {
            await _store.followUser();
          },
        )
      ],
    );
  }

  String toShortTime(String dateString) {
    try {
      var formatter = new DateFormat('yyyy-MM-dd HH:mm:ss');
      return formatter.format(DateTime.parse(dateString));
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    final IllustDetailStore _store = IllustDetailStore(illust);
    return SelectionArea(
      child: Observer(builder: (context) {
        return Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _buildNameAvatar(context, illust, _store),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text(I18n.of(context).illust_id),
                        Container(
                          width: 10.0,
                        ),
                        colorText(illust.id.toString(), context),
                        Container(
                          width: 20.0,
                        ),
                        Text(I18n.of(context).pixel),
                        Container(
                          width: 10.0,
                        ),
                        colorText("${illust.width}x${illust.height}", context)
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text(I18n.of(context).total_view),
                        Container(
                          width: 10.0,
                        ),
                        colorText(illust.totalView.toString(), context),
                        Container(
                          width: 20.0,
                        ),
                        Text(I18n.of(context).total_bookmark),
                        Container(
                          width: 10.0,
                        ),
                        colorText("${illust.totalBookmarks}", context)
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 2, // gap between adjacent chips
                  runSpacing: 0, // gap between lines
                  children: [
                    if (illust.illustAIType == 2)
                      Text("${I18n.of(context).ai_generated}",
                          style: FluentTheme.of(context)
                              .typography
                              .caption!
                              .copyWith(
                                  color: FluentTheme.of(context).accentColor)),
                    for (var f in illust.tags) buildRow(context, f)
                  ],
                ),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SelectableHtml(
                    data: illust.caption.isEmpty ? "~" : illust.caption,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: HyperlinkButton(
                  child: Text(I18n.of(context).view_comment,
                      textAlign: TextAlign.center,
                      style: FluentTheme.of(context).typography.body!),
                  onPressed: () {
                    Leader.push(
                      context,
                      CommentPage(
                        id: illust.id,
                      ),
                      icon: Icon(FluentIcons.comment),
                      title: Text(I18n.of(context).view_comment),
                    );
                  },
                ),
              )
            ],
          ),
        );
      }),
    );
  }

  Widget buildRow(BuildContext context, Tags f) {
    return RowCard(f);
  }
}
