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
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:mobx/mobx.dart';
import 'package:pixez/models/comment_response.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/comment/comment_page.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

part 'comment_store.g.dart';

class CommentStore = _CommentStoreBase with _$CommentStore;

final emojisMap = {
  '(normal)': '101.png',
  '(surprise)': '102.png',
  '(serious)': '103.png',
  '(heaven)': '104.png',
  '(happy)': '105.png',
  '(excited)': '106.png',
  '(sing)': '107.png',
  '(cry)': '108.png',
  '(normal2)': '201.png',
  '(shame2)': '202.png',
  '(love2)': '203.png',
  '(interesting2)': '204.png',
  '(blush2)': '205.png',
  '(fire2)': '206.png',
  '(angry2)': '207.png',
  '(shine2)': '208.png',
  '(panic2)': '209.png',
  '(normal3)': '301.png',
  '(satisfaction3)': '302.png',
  '(surprise3)': '303.png',
  '(smile3)': '304.png',
  '(shock3)': '305.png',
  '(gaze3)': '306.png',
  '(wink3)': '307.png',
  '(happy3)': '308.png',
  '(excited3)': '309.png',
  '(love3)': '310.png',
  '(normal4)': '401.png',
  '(surprise4)': '402.png',
  '(serious4)': '403.png',
  '(love4)': '404.png',
  '(shine4)': '405.png',
  '(sweat4)': '406.png',
  '(shame4)': '407.png',
  '(sleep4)': '408.png',
  '(heart)': '501.png',
  '(teardrop)': '502.png',
  '(star)': '503.png'
};

abstract class _CommentStoreBase with Store {
  String? nextUrl;
  @observable
  ObservableList<Comment> comments = ObservableList();
  @observable
  String? errorMessage;
  @observable
  bool isEmpty = false;
  final RefreshController _controller;
  final int id;
  final CommentArtWorkType type;
  int? pId;
  final bool isReplay;

  _CommentStoreBase(
      this._controller, this.id, this.pId, this.isReplay, this.type);

  @action
  fetch() async {
    errorMessage = null;
    nextUrl = null;
    _controller.footerMode?.value = LoadStatus.idle;
    _controller.headerMode?.value = RefreshStatus.refreshing;
    try {
      Response response = type == CommentArtWorkType.ILLUST
          ? (isReplay
              ? await apiClient.getIllustCommentsReplies(pId!)
              : await apiClient.getIllustComments(id))
          : (isReplay
              ? await apiClient.getNovelCommentsReplies(pId!)
              : await apiClient.getNovelComments(id));
      CommentResponse commentResponse = CommentResponse.fromJson(response.data);
      nextUrl = commentResponse.nextUrl;
      comments.clear();
      comments.addAll(commentResponse.comments);
      isEmpty = comments.isEmpty;
      _controller.refreshCompleted();
    } catch (e) {
      errorMessage = e.toString();
      _controller.refreshFailed();
    }
  }

  @action
  next() async {
    if (nextUrl != null && nextUrl!.isNotEmpty) {
      try {
        Response response = await apiClient.getNext(nextUrl!);
        CommentResponse commentResponse =
            CommentResponse.fromJson(response.data);
        nextUrl = commentResponse.nextUrl;
        comments.addAll(commentResponse.comments);
        _controller.loadComplete();
      } catch (e) {
        _controller.loadFailed();
      }
    } else {
      _controller.loadNoData();
    }
  }
}
