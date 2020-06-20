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
import 'package:pixez/models/tags.dart';

import './bloc.dart';

class TagHistoryBloc extends Bloc<TagHistoryEvent, TagHistoryState> {
  @override
  TagHistoryState get initialState => InitialTagHistoryState();

  @override
  Stream<TagHistoryState> mapEventToState(
    TagHistoryEvent event,
  ) async* {
    if (event is FetchAllTagHistoryEvent) {
      TagsPersistProvider tagsPersistProvider = TagsPersistProvider();
      await tagsPersistProvider.open();
      final results = await tagsPersistProvider.getAllAccount();
      yield TagHistoryDataState(results);
    }
    if (event is DeleteAllTagHistoryEvent) {
      TagsPersistProvider tagsPersistProvider = TagsPersistProvider();
      await tagsPersistProvider.open();
      final result = await tagsPersistProvider.deleteAll();
      yield TagHistoryDataState([]);
    }
    if(event is InsertTagHistoryEvent){
      TagsPersistProvider tagsPersistProvider = TagsPersistProvider();
      await tagsPersistProvider.open();
   final result= await  tagsPersistProvider.insert(event.tagsPersist);
      final results = await tagsPersistProvider.getAllAccount();
      yield TagHistoryDataState(results);
    }
  }
}
