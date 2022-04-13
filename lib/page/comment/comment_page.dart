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

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/component/comment_emoji_text.dart';
import 'package:pixez/component/painter_avatar.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/constants.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/exts.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/comment/comment_store.dart';
import 'package:pixez/page/comment/fluent_comment_state.dart';
import 'package:pixez/page/comment/material_comment_state.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

enum CommentArtWorkType { ILLUST, NOVEL }

class CommentPage extends StatefulWidget {
  final int id;
  final bool isReplay;
  final int? pId;
  final String? name;
  final CommentArtWorkType type;

  const CommentPage(
      {Key? key,
      required this.id,
      this.isReplay = false,
      this.pId,
      this.name,
      this.type = CommentArtWorkType.ILLUST})
      : super(key: key);

  @override
  CommentPageStateBase createState() {
    if (Constants.isFluentUI)
      return FluentCommentPageState();
    else
      return MaterialCommentPageState();
  }
}

abstract class CommentPageStateBase extends State<CommentPage> {
  late TextEditingController editController;
  int? parentCommentId;
  String? parentCommentName;
  late RefreshController easyRefreshController;
  late CommentStore store;

  List<String> banList = [
    "bb8.news",
    "77k.live",
    "7mm.live",
    "p26w.com",
    "33h.live"
  ];

  @override
  void initState() {
    parentCommentId = widget.isReplay ? widget.pId : null;
    parentCommentName = widget.isReplay ? widget.name : null;
    editController = TextEditingController();
    easyRefreshController = RefreshController();
    store = CommentStore(easyRefreshController, widget.id, widget.pId,
        widget.isReplay, widget.type)
      ..fetch();
    super.initState();
  }

  @override
  void dispose() {
    editController.dispose();
    easyRefreshController.dispose();
    super.dispose();
  }

}
