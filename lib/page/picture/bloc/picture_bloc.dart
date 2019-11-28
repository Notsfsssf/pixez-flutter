import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:pixez/network/api_client.dart';

import './bloc.dart';

class PictureBloc extends Bloc<PictureEvent, PictureState> {
  final ApiClient client;

  PictureBloc(this.client);

  @override
  PictureState get initialState => InitialPictureState();

  @override
  Stream<PictureState> mapEventToState(PictureEvent event,) async* {
    if (event is StarEvent) {
      if (!event.illusts.isBookmarked) {
        try {
          Response response =
          await client.postLikeIllust(event.illusts.id, "public", null);
          yield DataState(event.illusts..isBookmarked = true);
        } catch (e) {}
      } else {
        try {
          Response response = await client.postUnLikeIllust(event.illusts.id);
          yield DataState(event.illusts..isBookmarked = false);
        } catch (e) {}
      }
    }
  }
}
