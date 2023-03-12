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

// To parse this JSON data, do
//
//     final onezeroResponse = onezeroResponseFromJson(jsonString);
import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'onezero_response.g.dart';

@JsonSerializable()
class OnezeroResponse {
  @JsonKey(name: 'Answer')
  List<OnezeroAnswer> answer;

  OnezeroResponse({required this.answer});

  factory OnezeroResponse.fromJson(Map<String, dynamic> json) =>
      _$OnezeroResponseFromJson(json);

  Map<String, dynamic> toJson() => _$OnezeroResponseToJson(this);
}

@JsonSerializable()
class OnezeroAnswer {
  String name;
  int type;
  String data;
  @JsonKey(name: 'TTL')
  int ttl;

  OnezeroAnswer(
      {required this.name,
      required this.type,
      required this.data,
      required this.ttl});

  factory OnezeroAnswer.fromJson(Map<String, dynamic> json) =>
      _$OnezeroAnswerFromJson(json);

  Map<String, dynamic> toJson() => _$OnezeroAnswerToJson(this);
}
