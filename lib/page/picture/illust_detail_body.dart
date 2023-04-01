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

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import 'package:pixez/component/painter_avatar.dart';
import 'package:pixez/component/selectable_html.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/ban_tag.dart';
import 'package:pixez/models/illust.dart';
import 'package:pixez/page/comment/comment_page.dart';
import 'package:pixez/page/picture/illust_detail_store.dart';
import 'package:pixez/page/search/result_page.dart';

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
        style: TextStyle(color: Theme.of(context).colorScheme.secondary),
      );

  Widget _buildNameAvatar(
      BuildContext context, Illusts illust, IllustDetailStore _store) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Padding(
            child: GestureDetector(
              onLongPress: () {
                _store.followUser();
              },
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
                                : Theme.of(context).colorScheme.secondary,
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
                      TextStyle(color: Theme.of(context).colorScheme.secondary),
                ),
                Container(
                  height: 4.0,
                ),
                Text(
                  illust.user.name,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  toShortTime(illust.createDate),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
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
    return Observer(builder: (context) {
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
                        style: Theme.of(context).textTheme.caption!.copyWith(
                            color: Theme.of(context).colorScheme.secondary)),
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
              child: TextButton(
                child: Text(I18n.of(context).view_comment,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyText1!),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) => CommentPage(
                            id: illust.id,
                          )));
                },
              ),
            )
          ],
        ),
      );
    });
  }

  Widget buildRow(BuildContext context, Tags f) {
    return GestureDetector(
      onLongPress: () async {
        await _longPressTag(context, f);
      },
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return ResultPage(
            word: f.name,
            translatedName: f.translatedName ?? "",
          );
        }));
      },
      child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
              text: "#${f.name}",
              children: [
                TextSpan(
                  text: " ",
                  style: Theme.of(context).textTheme.caption,
                ),
                TextSpan(
                    text: "${f.translatedName ?? ""}",
                    style: Theme.of(context).textTheme.caption)
              ],
              style: Theme.of(context)
                  .textTheme
                  .caption!
                  .copyWith(color: Theme.of(context).colorScheme.secondary))),
    );
  }

  Future _longPressTag(BuildContext context, Tags f) async {
    switch (await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: Text(f.name),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 0);
                },
                child: Text(I18n.of(context).ban),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 1);
                },
                child: Text(I18n.of(context).bookmark),
              ),
            ],
          );
        })) {
      case 0:
        {
          muteStore.insertBanTag(BanTagPersist(
            name: f.name,
            translateName: f.translatedName ?? "",
          ));
        }
        break;
      case 1:
        {
          bookTagStore.bookTag(f.name);
        }
        break;
    }
  }
}
