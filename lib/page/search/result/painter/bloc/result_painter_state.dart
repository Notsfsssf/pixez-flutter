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

import 'package:meta/meta.dart';
import 'package:pixez/models/user_preview.dart';

@immutable
abstract class ResultPainterState {}
  
class InitialResultPainterState extends ResultPainterState {}
class  ResultPainterDataState extends ResultPainterState {
  final List<UserPreviews> userPreviews;
  final String nextUrl;

  ResultPainterDataState(this.userPreviews, this.nextUrl);
}

class LoadMoreState extends ResultPainterState {
  final bool success;
  final bool noMore;

  LoadMoreState({@required this.success, @required this.noMore});
}

class RefreshState extends ResultPainterState {
  final bool success;

  RefreshState({this.success});
}
