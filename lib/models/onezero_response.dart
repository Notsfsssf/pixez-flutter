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

OnezeroResponse onezeroResponseFromJson(String str) =>
    OnezeroResponse.fromJson(json.decode(str));

String onezeroResponseToJson(OnezeroResponse data) =>
    json.encode(data.toJson());

class OnezeroResponse {
  int status;
  bool tc;
  bool rd;
  bool ra;
  bool ad;
  bool cd;
  List<Question> question;
  List<Answer> answer;

  OnezeroResponse({
    required this.status,
    required this.tc,
    required this.rd,
    required this.ra,
    required this.ad,
    required this.cd,
    required this.question,
    required this.answer,
  });

  factory OnezeroResponse.fromJson(Map<String, dynamic> json) =>
      OnezeroResponse(
        status: json["Status"],
        tc: json["TC"],
        rd: json["RD"],
        ra: json["RA"],
        ad: json["AD"],
        cd: json["CD"],
        question: List<Question>.from(
            json["Question"].map((x) => Question.fromJson(x))),
        answer:
            List<Answer>.from(json["Answer"].map((x) => Answer.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "Status": status,
        "TC": tc,
        "RD": rd,
        "RA": ra,
        "AD": ad,
        "CD": cd,
        "Question": List<dynamic>.from(question.map((x) => x.toJson())),
        "Answer": List<dynamic>.from(answer.map((x) => x.toJson())),
      };
}

class Answer {
  String name;
  int type;
  int ttl;
  String data;

  Answer({
    required this.name,
    required this.type,
    required this.ttl,
    required this.data,
  });

  factory Answer.fromJson(Map<String, dynamic> json) => Answer(
        name: json["name"],
        type: json["type"],
        ttl: json["TTL"],
        data: json["data"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "type": type,
        "TTL": ttl,
        "data": data,
      };
}

class Question {
  String name;
  int type;

  Question({
    required this.name,
    required this.type,
  });

  factory Question.fromJson(Map<String, dynamic> json) => Question(
        name: json["name"],
        type: json["type"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "type": type,
      };
}
