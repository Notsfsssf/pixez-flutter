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
import 'package:pixez/models/illust_persist.dart';

import './bloc.dart';

class IllustPersistBloc extends Bloc<IllustPersistEvent, IllustPersistState> {
  @override
  IllustPersistState get initialState => InitialIllustPersistState();

  @override
  Stream<IllustPersistState> mapEventToState(
    IllustPersistEvent event,
  ) async* {
    if (event is FetchIllustPersistEvent) {
      IllustPersistProvider illustPersistProvider = IllustPersistProvider();
      await illustPersistProvider.open();
      final result = await illustPersistProvider.getAllAccount();
      yield DataIllustPersistState(result);
    }
    if (event is InsertIllustPersistEvent) {
      final illust = event.illusts;
      IllustPersistProvider illustPersistProvider = IllustPersistProvider();
      await illustPersistProvider.open();
      await illustPersistProvider.insert(IllustPersist()
        ..time = DateTime.now().millisecondsSinceEpoch
        ..userId = illust.user.id
        ..pictureUrl = illust.imageUrls.squareMedium
        ..illustId = illust.id);
    }
    if (event is DeleteIllustPersistEvent) {
      final id = event.id;
      IllustPersistProvider illustPersistProvider = IllustPersistProvider();
      await illustPersistProvider.open();
      await illustPersistProvider.delete(id);
      final result = await illustPersistProvider.getAllAccount();
      yield DataIllustPersistState(result);
    }
    if (event is DeleteAllIllustPersistEvent) {
      IllustPersistProvider illustPersistProvider = IllustPersistProvider();
      await illustPersistProvider.open();
      await illustPersistProvider.deleteAll();
      final result = await illustPersistProvider.getAllAccount();
      yield DataIllustPersistState(result);
    }
  }
}
