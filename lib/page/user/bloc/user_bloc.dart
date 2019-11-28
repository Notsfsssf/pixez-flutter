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
        // JsonEncoder encoder = new JsonEncoder.withIndent('  ');
        // String prettyprint = encoder.convert(response.data);
        // debugPrint(prettyprint);
        UserDetail userDetail = UserDetail.fromJson(response.data);
        yield UserDataState(userDetail);
      } on DioError catch (e) {

      }
    }
  }
}
