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
import 'package:pixez/network/account_client.dart';

import './bloc.dart';

class AccountEditBloc extends Bloc<AccountEditEvent, AccountEditState> {
  @override
  AccountEditState get initialState => InitialAccountEditState();

  @override
  Stream<AccountEditState> mapEventToState(
    AccountEditEvent event,
  ) async* {
    if (event is FetchAccountEditEvent) {
      try {
        final client = AccountClient();
        var response = await client.accountEdit(
            newMailAddress: event.newMailAddress,
            newPassword: event.newPassword,
            currentPassword: event.oldPassword,
            newUserAccount: event.newUserAccount);
        print(response.data);
        yield SuccessAccountEditState();
      } catch (e) {
        if (e is DioError) {
          try {
            var a = e.response.data['body']['validation_errors'].toString();
            yield FailAccountEditState(a);
          } catch (e) {
            yield FailAccountEditState(e);
          }
        } else {
          print(e);
          yield FailAccountEditState(e);
        }
      }
    }
  }
}
