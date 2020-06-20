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
import 'package:package_info/package_info.dart';

import './bloc.dart';

class AboutBloc extends Bloc<AboutEvent, AboutState> {
  @override
  AboutState get initialState => InitialAboutState();

  @override
  Stream<AboutState> mapEventToState(
    AboutEvent event,
  ) async* {
    if (event is FetchAboutEvent) {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      yield DataAbouState(packageInfo);
    }
  }
}
