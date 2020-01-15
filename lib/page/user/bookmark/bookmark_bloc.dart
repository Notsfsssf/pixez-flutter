import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:pixez/models/recommend.dart';
import 'package:pixez/network/api_client.dart';

import './bloc.dart';

class BookmarkBloc extends Bloc<BookmarkEvent, BookmarkState> {
  final ApiClient client;

  BookmarkBloc(this.client);

  @override
  BookmarkState get initialState => InitialBookmarkState();

  @override
  Stream<BookmarkState> mapEventToState(
    BookmarkEvent event,
  ) async* {
    if (event is FetchBookmarkEvent) {
      try {
        final response =
        await client.getBookmarksIllust(event.user_id, event.type, null);
        Recommend recommend = Recommend.fromJson(response.data);
        yield DataBookmarkState(recommend.illusts, recommend.nextUrl);
      } catch (e) {
        print(e);
        yield FailWorkState();
      }
    }
    if (event is LoadMoreEvent) {
      if (event.nextUrl != null) {
        try {
          final response = await client.getNext(event.nextUrl);
          Recommend recommend = Recommend.fromJson(response.data);
          final ill = event.illusts..addAll(recommend.illusts);
          print(ill.length);
          yield DataBookmarkState(ill, recommend.nextUrl);
        } catch (e) {
          yield LoadMoreFailState();
        }
      } else {
        yield LoadMoreEndState();
      }
    }
  }
}
