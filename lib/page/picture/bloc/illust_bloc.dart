import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:pixez/models/error_message.dart';
import 'package:pixez/models/illust.dart';
import 'package:pixez/network/api_client.dart';

import './bloc.dart';

class IllustBloc extends Bloc<IllustEvent, IllustState> {
  final ApiClient client;

  final int id;

  Illusts illust;

  IllustBloc(this.client, this.id, {this.illust});

  @override
  IllustState get initialState => InitialIllustState();

  @override
  Stream<IllustState> mapEventToState(
    IllustEvent event,
  ) async* {
    if (event is FetchIllustDetailEvent) {
      if (illust == null) {
        try {
          Response response = await client.getIllustDetail(id);
          yield DataIllustState(Illusts.fromJson(response.data['illust']));
        } on DioError catch (e) {
          if (e.response != null) {
            ErrorMessage errorMessage = ErrorMessage.fromJson(e.response.data);
            yield FZFIllustState(errorMessage);
          }
        }
      } else
        yield DataIllustState(illust);
    }
  }
}
