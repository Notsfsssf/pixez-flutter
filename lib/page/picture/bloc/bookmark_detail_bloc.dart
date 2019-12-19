import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:pixez/models/bookmark_detail.dart';
import 'package:pixez/network/api_client.dart';
import './bloc.dart';

class BookmarkDetailBloc
    extends Bloc<BookmarkDetailEvent, BookmarkDetailState> {
  final ApiClient client;

  BookmarkDetailBloc(this.client);
  @override
  BookmarkDetailState get initialState => InitialBookmarkDetailState();

  @override
  Stream<BookmarkDetailState> mapEventToState(
    BookmarkDetailEvent event,
  ) async* {
    if (event is FetchBookmarkDetailEvent) {
      try {
        Response response = await client.getIllustBookmarkDetail(event.id);
        BookMarkDetailResponse bookMarkDetailResponse =
            BookMarkDetailResponse.fromJson(response.data);
        yield DataBookmarkDetailState(bookMarkDetailResponse);
      } catch (e) {}
    }
  }
}
