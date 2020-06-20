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
import 'package:pixez/models/illust.dart';

abstract class PictureEvent extends Equatable {
  const PictureEvent();
}

class StarPictureEvent extends PictureEvent {
  final Illusts illusts;
  final String restrict;
  final List<String> tags;

  StarPictureEvent(this.illusts, this.restrict, this.tags);

  @override
  List<Object> get props => [illusts];
}

class UnStarPictureEvent extends PictureEvent {
  final Illusts illusts;

  UnStarPictureEvent(this.illusts);

  @override
  List<Object> get props => [illusts];
}
