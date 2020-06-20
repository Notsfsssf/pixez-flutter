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

@immutable
abstract class MuteEvent {}

class FetchMuteEvent extends MuteEvent {}

class InsertBanUserEvent extends MuteEvent {
  final String id;
  final String name;

  InsertBanUserEvent(this.id, this.name);
}

class InsertBanTagEvent extends MuteEvent {
  final String name, translateName;

  InsertBanTagEvent(this.name, this.translateName);
}

class InsertBanIllustEvent extends MuteEvent {
  final String id;
  final String name;

  InsertBanIllustEvent(this.id, this.name);
}

class DeleteIllustEvent extends MuteEvent {
  final int id;

  DeleteIllustEvent(this.id);
}

class DeleteUserEvent extends MuteEvent {
  final int id;

  DeleteUserEvent(this.id);
}

class DeleteTagEvent extends MuteEvent {
  final int id;

  DeleteTagEvent(this.id);
}
