import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
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
        Response response = await client.getIllustDetail(id);
        yield DataIllustState(Illusts.fromJson(response.data['illust']));
      } else
        yield DataIllustState(illust);
    }
  }
}
