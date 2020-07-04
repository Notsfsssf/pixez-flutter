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
import 'package:pixez/models/ban_illust_id.dart';
import 'package:pixez/models/ban_tag.dart';
import 'package:pixez/models/ban_user_id.dart';

import './bloc.dart';

@Deprecated('mobx')
class MuteBloc extends Bloc<MuteEvent, MuteState> {
  BanIllustIdProvider banIllustIdProvider = BanIllustIdProvider();
  var banUserIdProvider = BanUserIdProvider();
  var banTagProvider = BanTagProvider();

  @override
  MuteState get initialState => InitialMuteState();

  @override
  Stream<MuteState> mapEventToState(
    MuteEvent event,
  ) async* {
    if (event is FetchMuteEvent) {
      await banIllustIdProvider.open();
      await banUserIdProvider.open();
      await banTagProvider.open();
      var illustids = await banIllustIdProvider.getAllAccount();
      var userids = await banUserIdProvider.getAllAccount();
      var tags = await banTagProvider.getAllAccount();
      yield DataMuteState(illustids, userids, tags);
    }
    if (event is InsertBanTagEvent) {
      await banTagProvider.open();
      await banTagProvider.insert(BanTagPersist()
        ..name = event.name
        ..translateName = event.translateName);
      add(FetchMuteEvent());
    }
    if (event is InsertBanIllustEvent) {
      await banIllustIdProvider.open();
      await banIllustIdProvider.insert(BanIllustIdPersist()
        ..illustId = event.id
        ..name = event.name);
      add(FetchMuteEvent());
    }
    if (event is InsertBanUserEvent) {
      await banUserIdProvider.open();
      await banUserIdProvider.insert(BanUserIdPersist()
        ..userId = event.id
        ..name = event.name);
      add(FetchMuteEvent());
    }
    if (event is DeleteUserEvent) {
      await banUserIdProvider.open();
      await banUserIdProvider.delete(event.id);
      add(FetchMuteEvent());
    }
    if (event is DeleteIllustEvent) {
      await banIllustIdProvider.open();
      await banIllustIdProvider.delete(event.id);
      add(FetchMuteEvent());
    }
    if (event is DeleteTagEvent) {
      await banTagProvider.open();
      await banTagProvider.delete(event.id);
      add(FetchMuteEvent());
    }
  }
}
