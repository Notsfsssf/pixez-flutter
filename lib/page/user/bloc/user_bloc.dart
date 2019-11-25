import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:pixez/network/api_client.dart';
import './bloc.dart';
import 'package:dio/dio.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  @override
  UserState get initialState => InitialUserState();

  @override
  Stream<UserState> mapEventToState(
    UserEvent event,
  ) async* {
    if (event is FetchEvent) {
      try {
        final client = ApiClient();
        Response response = await client.getUser(event.id);
        print(response.data);
      } on DioError catch (e) {

      }
    }
  }
}
