import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:pixez/models/recommend.dart';
import 'package:pixez/network/api_client.dart';

import './bloc.dart';

class BookmarkBloc extends Bloc<BookmarkEvent, BookmarkState> {
  final ApiClient client;
  String tag;

  BookmarkBloc(this.client, this.tag);

  @override
  BookmarkState get initialState => InitialBookmarkState();

  @override
  Stream<BookmarkState> mapEventToState(
    BookmarkEvent event,
  ) async* {
    if (event is FetchBookmarkEvent) {
      try {
        tag = event.tags;
        final response = await client.getBookmarksIllust(
            event.user_id, event.type, event.tags);
        Recommend recommend = Recommend.fromJson(response.data);
        yield DataBookmarkState(recommend.illusts, recommend.nextUrl, tag);
        yield RefreshState(success: true);
      } catch (e) {
        print(e);
        yield RefreshState(success: false);
      }
    }
    if (event is LoadMoreEvent) {
      if (event.nextUrl != null) {
        try {
          final response = await client.getNext(event.nextUrl);
          Recommend recommend = Recommend.fromJson(response.data);
          final ill = event.illusts..addAll(recommend.illusts);
          print(ill.length);
          yield DataBookmarkState(ill, recommend.nextUrl, tag);
          yield LoadMoreState(success: true, noMore: false);
        } catch (e) {
          yield LoadMoreState(success: false, noMore: false);
        }
      } else {
        yield LoadMoreState(success: true, noMore: true);
      }
    }
  }
}
