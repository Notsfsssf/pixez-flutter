import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pixez/models/account.dart';
import 'package:pixez/network/oauth_client.dart';
import 'package:dio/dio.dart';
import './bloc.dart';
import 'package:bloc/bloc.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  @override
  LoginState get initialState => InitialLoginState();

  @override
  Stream<LoginState> mapEventToState(
    LoginEvent event,
  ) async* {
    if (event is ClickToAuth) {
      final client = new OAuthClient();

      try {
        final response =
            await client.postAuthToken(event.username, event.password);
        AccountResponse accountResponse =
            Account.fromJson(response.data).response;
        AccountProvider accountProvider = new AccountProvider();
        await accountProvider.open();
        accountProvider.insert(AccountPersist()
          ..accessToken = accountResponse.accessToken
          ..deviceToken = accountResponse.deviceToken
          ..refreshToken = accountResponse.refreshToken
          ..expiresIn = accountResponse.expiresIn
          ..scope = accountResponse.scope);
        yield SuccessState();
      } on DioError catch (e) {
        // The request was made and the server responded with a status code
        // that falls out of the range of 2xx and is also not 304.
        if (e == null) {
          return;
        }
        if (e.response != null) {

          print(e.response.data);
          print(e.response.headers);
          print(e.response.request);
          yield FailState(e.response.data);
        } else {
          // Something happened in setting up or sending the request that triggered an Error
          print(e.request);
          print(e.message);
        }
      }
    }
  }
}
