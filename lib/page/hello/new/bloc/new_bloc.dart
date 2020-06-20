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

import './bloc.dart';

class NewBloc extends Bloc<NewEvent, NewState> {
  @override
  NewState get initialState => InitialNewState();

  @override
  Stream<NewState> mapEventToState(
    NewEvent event,
  ) async* {
    if(event is NewInitalEvent){
      yield NewDataRestrictState("${event.newRestrict}","${event.bookRestrict}","${event.painterRestrict}");
    }
    if (event is RestrictEvent) {
      yield NewDataRestrictState("${event.newRestrict}","${event.bookRestrict}","${event.painterRestrict}");
    }

  }
}
