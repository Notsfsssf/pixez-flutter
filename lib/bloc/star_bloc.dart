import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:pixez/models/illust.dart';
import 'package:pixez/network/api_client.dart';

import './bloc.dart';

class StarBloc extends Bloc<StarEvent, StarState> {
  final ApiClient client;
  final Illusts illusts;

  StarBloc(this.client, this.illusts);

  @override
  StarState get initialState => InitialStarState(this.illusts.isBookmarked);

  @override
  Stream<StarState> mapEventToState(
    StarEvent event,
  ) async* {
    if (event is ToStarEvent) {
      try {
        Illusts illusts = event.illusts;
        if (illusts.isBookmarked) {
          return;
        }
        await client.postLikeIllust(
            event.illusts.id, event.restrict, event.tags);

        illusts.isBookmarked = true;
        yield InitialStarState(illusts.isBookmarked);
      } catch (e) {}
    }
    if (event is UnStarEvent) {
      try {
        Illusts illusts = event.illusts;
        if (illusts.isBookmarked) {
          return;
        }
        await client.postUnLikeIllust(event.illusts.id);
        illusts.isBookmarked = false;
        yield InitialStarState(illusts.isBookmarked);
      } catch (e) {}
    }
  }
}
