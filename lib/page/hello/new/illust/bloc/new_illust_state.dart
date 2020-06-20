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

import 'package:pixez/models/illust.dart';

abstract class NewIllustState {
  const NewIllustState();
}

class InitialNewIllustState extends NewIllustState {}

class FailIllustState extends NewIllustState {}

class RefreshFailIllustState extends NewIllustState {}

class DataNewIllustState extends NewIllustState {
  final List<Illusts> illusts;
  final String nextUrl;

  DataNewIllustState(this.illusts, this.nextUrl);
}

class LoadMoreSuccessState extends NewIllustState {
}
