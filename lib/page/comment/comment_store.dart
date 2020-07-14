import 'package:dio/dio.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:mobx/mobx.dart';
import 'package:pixez/models/comment_response.dart';
import 'package:pixez/network/api_client.dart';
part 'comment_store.g.dart';

class CommentStore = _CommentStoreBase with _$CommentStore;

abstract class _CommentStoreBase with Store {
  String nextUrl;
  ObservableList<Comment> comments = ObservableList();
  final EasyRefreshController _controller;
  final int id;
  _CommentStoreBase(this._controller, this.id);
  @action
  fetch() async {
    nextUrl = null;
    try {
      Response response = await apiClient.getIllustComments(id);
      CommentResponse commentResponse = CommentResponse.fromJson(response.data);
      nextUrl = commentResponse.nextUrl;
      comments.clear();
      comments.addAll(commentResponse.comments);
      _controller.finishLoad(success: true);
    } catch (e) {
      _controller.finishLoad(success: false);
    }
  }

  @action
  next() async {
    if (nextUrl != null && nextUrl.isNotEmpty) {
      try {
        Response response = await apiClient.getNext(nextUrl);
        CommentResponse commentResponse =
            CommentResponse.fromJson(response.data);
        nextUrl = commentResponse.nextUrl;
        comments.addAll(commentResponse.comments);
        _controller.finishLoad(success: true, noMore: false);
      } catch (e) {
        _controller.finishLoad(success: false);
      }
    } else {
      _controller.finishLoad(success: true, noMore: true);
    }
  }
}
