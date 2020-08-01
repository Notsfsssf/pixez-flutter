import 'package:dio/dio.dart';
import 'package:mobx/mobx.dart';
import 'package:pixez/models/comment_response.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
part 'comment_store.g.dart';

class CommentStore = _CommentStoreBase with _$CommentStore;

abstract class _CommentStoreBase with Store {
  String nextUrl;
  ObservableList<Comment> comments = ObservableList();
  final RefreshController _controller;
  final int id;
  _CommentStoreBase(this._controller, this.id);
  @action
  fetch() async {
    nextUrl = null;
    _controller?.footerMode?.value = LoadStatus.idle;
    try {
      Response response = await apiClient.getIllustComments(id);
      CommentResponse commentResponse = CommentResponse.fromJson(response.data);
      nextUrl = commentResponse.nextUrl;
      comments.clear();
      comments.addAll(commentResponse.comments);
      _controller.refreshCompleted();
    } catch (e) {
      _controller.refreshFailed();
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
        _controller.loadComplete();
      } catch (e) {
        _controller.loadFailed();
      }
    } else {
      _controller.loadNoData();
    }
  }
}
