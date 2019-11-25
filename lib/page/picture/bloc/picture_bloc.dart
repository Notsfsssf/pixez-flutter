import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:pixez/network/api_client.dart';
import './bloc.dart';
import 'package:dio/dio.dart';

class PictureBloc extends Bloc<PictureEvent, PictureState> {
  @override
  PictureState get initialState => InitialPictureState();

  @override
  Stream<PictureState> mapEventToState(
    PictureEvent event,
  ) async* {
    if (event is StarEvent) {
      if (!event.illusts.isBookmarked) {
        try {
          final client = ApiClient();
          Response response = await client.getLikeIllust();
          yield DataState(event.illusts..isBookmarked = true);
        } catch (e) {}
      } else {
        try {
          final client = ApiClient();
          Response response = await client.getUnlikeIllust();
          yield DataState(event.illusts..isBookmarked = false);
        } catch (e) {}
      }
    }
  }
}
