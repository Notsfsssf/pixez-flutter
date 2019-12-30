import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:pixez/models/illust.dart';
import 'package:pixez/network/api_client.dart';

import './bloc.dart';

class PictureBloc extends Bloc<PictureEvent, PictureState> {
  final ApiClient client;

  PictureBloc(this.client);

  @override
  PictureState get initialState => InitialPictureState();

  @override
  Stream<PictureState> mapEventToState(
    PictureEvent event,
  ) async* {
    if (event is StarPictureEvent) {
      if (!event.illusts.isBookmarked) {
        try {
          Response response = await client.postLikeIllust(
              event.illusts.id, event.restrict, event.tags);
          Illusts illusts = event.illusts;
          illusts.isBookmarked = true;
          yield DataState(illusts);
        } catch (e) {}
      } else {
        try {
          Response response = await client.postUnLikeIllust(event.illusts.id);
          Illusts illusts = event.illusts;
          illusts.isBookmarked = false;
          yield DataState(illusts);
        } catch (e) {}
      }
    }


  }
}
