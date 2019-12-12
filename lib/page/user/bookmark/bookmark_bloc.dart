import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:pixez/models/recommend.dart';
import 'package:pixez/network/api_client.dart';

import './bloc.dart';

class BookmarkBloc extends Bloc<BookmarkEvent, BookmarkState> {
  @override
  BookmarkState get initialState => InitialBookmarkState();

  @override
  Stream<BookmarkState> mapEventToState(
    BookmarkEvent event,
  ) async* {
    if (event is FetchBookmarkEvent) {
      final client = new ApiClient();
      try {
        final response =
            await client.getBookmarksIllust(event.user_id, event.type, null);
        Recommend recommend = Recommend.fromJson(response.data);
        yield DataBookmarkState(recommend.illusts, recommend.nextUrl);
      } catch (e) {
        if (e == null) {
          return;
        }
        print(e);
      }
    }
    if (event is LoadMoreEvent) {
      final client = new ApiClient();
      if (event.nextUrl != null) {
        try {
          final response = await client.getNext(event.nextUrl);
          Recommend recommend = Recommend.fromJson(response.data);
          final ill = event.illusts..addAll(recommend.illusts);
          print(ill.length);
          yield DataBookmarkState(ill, recommend.nextUrl);
        } catch (e) {}
      } else {}
    }
  }
}
