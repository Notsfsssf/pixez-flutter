import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:pixez/models/user_preview.dart';
import 'package:pixez/network/api_client.dart';
import './bloc.dart';

class NewPainterBloc extends Bloc<NewPainterEvent, NewPainterState> {
  final ApiClient client;

  NewPainterBloc(this.client);

  @override
  NewPainterState get initialState => InitialNewPainterState();

  @override
  Stream<NewPainterState> mapEventToState(
    NewPainterEvent event,
  ) async* {
    if (event is FetchPainterEvent) {
      try {
        final response = await client.getUserFollowing(event.id, event.retrict);
        UserPreviewsResponse userPreviews =
            UserPreviewsResponse.fromJson(response.data);
        yield DataState(userPreviews.user_previews, userPreviews.next_url);
      } catch (e) {
      yield FailState();
      }
    }
    if (event is LoadMoreEvent) {
      try {
        if (event.nextUrl != null) {
          final response = await client.getNext(event.nextUrl);
          UserPreviewsResponse userPreviews =
              UserPreviewsResponse.fromJson(response.data);
          yield DataState(event.users..addAll(userPreviews.user_previews),
              userPreviews.next_url);
        } else {
          yield LoadEndState();
        }
      } catch (e) {}
    }
  }
}
