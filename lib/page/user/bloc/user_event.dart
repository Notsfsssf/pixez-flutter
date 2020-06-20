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

import 'package:equatable/equatable.dart';
import 'package:pixez/models/user_detail.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();
}
class FetchEvent extends UserEvent {
  final int id;

  FetchEvent(this.id);

  @override
  List<Object> get props => [id];
}

class ShowSheetEvent extends UserEvent {
  @override
  List<Object> get props => [];
}

class ChoiceRestrictEvent extends UserEvent {
  final String restrict;

  final UserDetail userDetail;

  ChoiceRestrictEvent(this.restrict, this.userDetail);

  @override
  List<Object> get props => [restrict, userDetail];
}
class FollowUserEvent extends UserEvent{
  final UserDetail userDetail;
  final String restrict,followRestrict;
  FollowUserEvent(this.userDetail, this.restrict,this.followRestrict);
  @override
  List<Object> get props => [userDetail,restrict,followRestrict];

}