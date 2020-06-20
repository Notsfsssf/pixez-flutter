/*
 * Copyright (C) 2020. by perol_notsf, All rights reserved
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program. If not, see <http://www.gnu.org/licenses/>.
 *
 */

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:pixez/models/account.dart';
import 'package:pixez/models/login_error_response.dart';
import 'package:pixez/network/oauth_client.dart';

import './bloc.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final OAuthClient client;

  LoginBloc(this.client);

  @override
  LoginState get initialState => InitialLoginState();

  int bti(bool bool) {
    if (bool) {
      return 1;
    } else
      return 0;
  }

  @override
  Stream<LoginState> mapEventToState(
    LoginEvent event,
  ) async* {
    if (event is NeedGuidEvent) {
      yield NeedGuidState();
    }
    if (event is ClickToAuth) {
      try {
        final response = await client.postAuthToken(
            event.username, event.password,
            deviceToken: event.deviceToken);
        AccountResponse accountResponse =
            Account.fromJson(response.data).response;
        User user = accountResponse.user;
        AccountProvider accountProvider = new AccountProvider();
        await accountProvider.open();
        print(accountResponse.accessToken);
        accountProvider.insert(AccountPersist()
          ..accessToken = accountResponse.accessToken
          ..passWord = event.password
          ..deviceToken = accountResponse.deviceToken
          ..refreshToken = accountResponse.refreshToken
          ..userImage = user.profileImageUrls.px170x170
          ..userId = user.id
          ..name = user.name
          ..isMailAuthorized = bti(user.isMailAuthorized)
          ..isPremium = bti(user.isPremium)
          ..mailAddress = user.mailAddress
          ..account = user.account
          ..xRestrict = user.xRestrict);
        yield SuccessState();
      } on DioError catch (e) {
        // The request was made and the server responded with a status code
        // that falls out of the range of 2xx and is also not 304.
        if (e == null) {
          return;
        }
        if (e.response.data != null)
          yield FailState(LoginErrorResponse.fromJson(e.response.data).errors.system.message);
        else
          yield FailState(e.message);
      }
    }
  }
}
