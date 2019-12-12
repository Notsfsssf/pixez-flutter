import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:pixez/models/user_detail.dart';
import 'package:pixez/network/api_client.dart';

import './bloc.dart';

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
        UserDetail userDetail = UserDetail.fromJson(response.data);
        yield UserDataState(userDetail, "public");
      } on DioError catch (e) {}
    }
    if (event is ShowSheetEvent) {
      yield ShowSheetState();
    }
    if (event is ChoiceRestrictEvent) {
      yield UserDataState(event.userDetail, "${event.restrict}");
    }
  }
}
