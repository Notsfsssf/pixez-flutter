import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:pixez/models/illust_bookmark_tags_response.dart';
import 'package:pixez/network/api_client.dart';

import './bloc.dart';

class UserBookmarkTagBloc
    extends Bloc<UserBookmarkTagEvent, UserBookmarkTagState> {
  final ApiClient client;

  UserBookmarkTagBloc(this.client);

  @override
  UserBookmarkTagState get initialState => InitialUserBookmarkTagState();

  @override
  Stream<UserBookmarkTagState> mapEventToState(
    UserBookmarkTagEvent event,
  ) async* {
    if (event is FetchUserBookmarkTagEvent) {
      try {
        var result = await client.getUserBookmarkTagsIllust(event.id,
            restrict: event.restrict);
        yield DataUserBookmarkTagState(result.bookmarkTags, result.nextUrl);
      } catch (e) {
        yield RefreshFail();
      }
    }
    if (event is LoadMoreUserBookmarkTagEvent) {
      if (event.nextUrl != null && event.nextUrl.isNotEmpty) {
        try {
          final result = await client.getNext(event.nextUrl);
          var r = IllustBookmarkTagsResponse.fromJson(result.data);
          yield DataUserBookmarkTagState(
              event.bookmarkTags..addAll(r.bookmarkTags), r.nextUrl);
        } catch (e) {
          yield LoadMoreFail();
        }
      } else {
        yield LoadMoreEnd();
      }
    }
  }
}
