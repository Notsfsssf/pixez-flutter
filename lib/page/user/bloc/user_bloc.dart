import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:pixez/models/user_detail.dart';
import 'package:pixez/network/api_client.dart';

import './bloc.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final ApiClient client;

  UserBloc(this.client);
  @override
  UserState get initialState => InitialUserState();

  @override
  Stream<UserState> mapEventToState(
    UserEvent event,
  ) async* {
    if (event is FetchEvent) {
      try {
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
    if (event is FollowUserEvent) {
      if (event.userDetail.user.is_followed) {
        try {
          Response response =
              await client.postUnFollowUser(event.userDetail.user.id);
          yield UserDataState(
              event.userDetail..user.is_followed = false, "${event.restrict}");
        } catch (e) {}
      } else {
        try {
          Response response = await client.postFollowUser(
              event.userDetail.user.id,event.followRestrict);
          yield UserDataState(
              event.userDetail..user.is_followed = true, "${event.restrict}");
        } catch (e) {}
      }
    }
  }
}
