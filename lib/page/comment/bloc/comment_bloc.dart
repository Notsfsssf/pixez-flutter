import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter_easyrefresh/src/refresher.dart';
import 'package:pixez/models/comment_response.dart';
import 'package:pixez/network/api_client.dart';

import './bloc.dart';

class CommentBloc extends Bloc<CommentEvent, CommentState> {
  final ApiClient client;

  EasyRefreshController easyRefreshController;

  CommentBloc(this.client, this.easyRefreshController);

  @override
  CommentState get initialState => InitialCommentState();

  @override
  Stream<CommentState> mapEventToState(
    CommentEvent event,
  ) async* {
    try {
      if (event is FetchCommentEvent) {
        Response response = await client.getIllustComments(event.id);
        CommentResponse commentResponse =
            CommentResponse.fromJson(response.data);
        yield DataCommentState(commentResponse);
      }
      if (event is LoadMoreCommentEvent) {
        var nextUrl = event.commentResponse.nextUrl;
        if (nextUrl != null && nextUrl.isNotEmpty) {
          Response response = await client.getNext(nextUrl);
          CommentResponse commentResponse =
              CommentResponse.fromJson(response.data);
          commentResponse.comments = event.commentResponse.comments
            ..addAll(commentResponse.comments);
          yield DataCommentState(commentResponse);
        } else {
          easyRefreshController.finishLoad(
              success: true, noMore: true); //??????
        }
      }
    } catch (e) {}
  }
}
