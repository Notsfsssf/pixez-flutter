import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:pixez/models/recommend.dart';
import 'package:pixez/network/api_client.dart';
import './bloc.dart';

class IllustRelatedBloc extends Bloc<IllustRelatedEvent, IllustRelatedState> {
  final ApiClient client;

  IllustRelatedBloc(this.client);

  @override
  IllustRelatedState get initialState => InitialIllustRelatedState();

  @override
  Stream<IllustRelatedState> mapEventToState(
    IllustRelatedEvent event,
  ) async* {
    if (event is FetchRelatedEvent) {
      Response response = await client.getIllustRelated(event.illusts.id);
      Recommend recommend = Recommend.fromJson(response.data);
      yield DataIllustRelatedState(recommend);//??????
    }
  }
}
