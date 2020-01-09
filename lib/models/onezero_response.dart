// To parse this JSON data, do
//
//     final onezeroResponse = onezeroResponseFromJson(jsonString);

import 'dart:convert';

OnezeroResponse onezeroResponseFromJson(String str) => OnezeroResponse.fromJson(json.decode(str));

String onezeroResponseToJson(OnezeroResponse data) => json.encode(data.toJson());

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
        this.status,
        this.tc,
        this.rd,
        this.ra,
        this.ad,
        this.cd,
        this.question,
        this.answer,
    });

    factory OnezeroResponse.fromJson(Map<String, dynamic> json) => OnezeroResponse(
        status: json["Status"],
        tc: json["TC"],
        rd: json["RD"],
        ra: json["RA"],
        ad: json["AD"],
        cd: json["CD"],
        question: List<Question>.from(json["Question"].map((x) => Question.fromJson(x))),
        answer: List<Answer>.from(json["Answer"].map((x) => Answer.fromJson(x))),
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
        this.name,
        this.type,
        this.ttl,
        this.data,
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
        this.name,
        this.type,
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
