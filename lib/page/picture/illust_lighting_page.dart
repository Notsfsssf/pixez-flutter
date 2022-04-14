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
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/component/ban_page.dart';
import 'package:pixez/component/null_hero.dart';
import 'package:pixez/component/painter_avatar.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/component/selectable_html.dart';
import 'package:pixez/component/star_icon.dart';
import 'package:pixez/constants.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/er/lprinter.dart';
import 'package:pixez/exts.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/ban_illust_id.dart';
import 'package:pixez/models/ban_tag.dart';
import 'package:pixez/models/illust.dart';
import 'package:pixez/page/comment/comment_page.dart';
import 'package:pixez/page/picture/fluent_illust_lighting_state.dart';
import 'package:pixez/page/picture/illust_about_store.dart';
import 'package:pixez/page/picture/illust_store.dart';
import 'package:pixez/page/picture/material_illust_lighting_state.dart';
import 'package:pixez/page/picture/picture_list_page.dart';
import 'package:pixez/page/picture/tag_for_illust_page.dart';
import 'package:pixez/page/picture/ugoira_loader.dart';
import 'package:pixez/page/search/result_page.dart';
import 'package:pixez/page/user/user_store.dart';
import 'package:pixez/page/user/users_page.dart';
import 'package:pixez/page/zoom/photo_viewer_page.dart';
import 'package:pixez/page/zoom/photo_zoom_page.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:share_plus/share_plus.dart';

class IllustLightingPage extends StatefulWidget {
  final int id;
  final String? heroString;
  final IllustStore? store;

  const IllustLightingPage(
      {Key? key, required this.id, this.heroString, this.store})
      : super(key: key);

  @override
  IllustLightingPageStateBase createState() {
    if (Constants.isFluentUI)
      return FluentIllustLightingPageState();
    else
      return MaterialIllustLightingPageState();
  }
}

abstract class IllustLightingPageStateBase extends State<IllustLightingPage>
    with AutomaticKeepAliveClientMixin {
  Future<void> pressSave(Illusts illust, int index) async {
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(16),
          ),
        ),
        builder: (c1) {
          return Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                illust.metaPages.isNotEmpty
                    ? ListTile(
                        title: Text(I18n.of(context).muti_choice_save),
                        leading: Icon(
                          Icons.save,
                        ),
                        onTap: () async {
                          Navigator.of(context).pop();
                          showMutiChoiceDialog(illust, context);
                        },
                      )
                    : Container(),
                ListTile(
                  leading: Icon(Icons.save_alt),
                  onTap: () async {
                    Navigator.of(context).pop();
                    saveStore.saveImage(illust, index: index);
                  },
                  title: Text(I18n.of(context).save),
                ),
                ListTile(
                  leading: Icon(Icons.cancel),
                  onTap: () => Navigator.of(context).pop(),
                  title: Text(I18n.of(context).cancel),
                ),
                Container(
                  height: MediaQuery.of(c1).padding.bottom,
                )
              ],
            ),
          );
        });
  }

  Future showMutiChoiceDialog(Illusts illust, BuildContext context) async {
    List<bool> indexs = [];
    bool allOn = false;
    for (int i = 0; i < illust.metaPages.length; i++) {
      indexs.add(false);
    }
    final result = await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.0))),
        builder: (context) {
          return StatefulBuilder(builder: (context, setDialogState) {
            return SafeArea(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.8,
                child: Column(
                  children: [
                    Container(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(illust.title),
                      ),
                    ),
                    Expanded(
                      child: GridView.builder(
                        itemBuilder: (context, index) {
                          final data = illust.metaPages[index];
                          return Container(
                              child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: InkWell(
                              onTap: () {
                                setDialogState(() {
                                  indexs[index] = !indexs[index];
                                });
                              },
                              onLongPress: () {
                                Leader.push(
                                    context,
                                    PhotoZoomPage(
                                        index: index, illusts: illust));
                              },
                              child: Stack(
                                children: [
                                  PixivImage(
                                    data.imageUrls!.squareMedium,
                                    placeWidget: Container(
                                      child: Center(
                                        child: Text(index.toString()),
                                      ),
                                    ),
                                  ),
                                  Align(
                                      alignment: Alignment.bottomRight,
                                      child: Visibility(
                                          visible: indexs[index],
                                          child: Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: Icon(
                                              Icons.check_circle,
                                              color: Colors.green,
                                            ),
                                          ))),
                                ],
                              ),
                            ),
                          ));
                        },
                        itemCount: illust.metaPages.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3),
                      ),
                    ),
                    ListTile(
                      leading: Icon(!allOn
                          ? Icons.check_circle_outline
                          : Icons.check_circle),
                      title: Text(I18n.of(context).all),
                      onTap: () {
                        allOn = !allOn;
                        for (var i = 0; i < indexs.length; i++) {
                          indexs[i] = allOn;
                        }
                        setDialogState(() {});
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.save),
                      title: Text(I18n.of(context).save),
                      onTap: () {
                        Navigator.of(context).pop("OK");
                      },
                    ),
                  ],
                ),
              ),
            );
          });
        });
    switch (result) {
      case "OK":
        {
          saveStore.saveChoiceImage(illust, indexs);
        }
    }
  }
}
