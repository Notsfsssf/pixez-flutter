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
import 'package:pixez/models/onezero_response.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/network/onezero_client.dart';

import './bloc.dart';

class OnezeroBloc extends Bloc<OnezeroEvent, OnezeroState> {
  final OnezeroClient onezeroClient;

  OnezeroBloc(this.onezeroClient);
  @override
  OnezeroState get initialState => InitialOnezeroState();

  @override
  Stream<OnezeroState> mapEventToState(
    OnezeroEvent event,
  ) async* {
    if (event is FetchOnezeroEvent) {
      try {
        OnezeroResponse onezeroResponse =
            await onezeroClient.queryDns(ApiClient.BASE_API_URL_HOST);
        yield DataOnezeroState(onezeroResponse);
      } catch (e) {
        print(e);
        yield FailOnezeroState();
      }
    }
  }
}
