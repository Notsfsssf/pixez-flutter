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
int bti(bool bool){
  if(bool){
    return 1;
  }else return 0;
}
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
        User user = accountResponse.user;
        AccountProvider accountProvider = new AccountProvider();
        await accountProvider.open();
        print(accountResponse.accessToken);
        accountProvider.insert(AccountPersist()
          ..accessToken = accountResponse.accessToken
          ..deviceToken = accountResponse.deviceToken
          ..refreshToken = accountResponse.refreshToken
          ..userImage = user.profileImageUrls.px170x170
          ..userId = user.id
          ..name = user.name
          ..isMailAuthorized = bti(user.isMailAuthorized)
          ..isPremium = bti(user.isPremium)
          ..mailAddress=user.mailAddress
          ..account = user.account
          ..xRestrict = user.xRestrict
      );
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
