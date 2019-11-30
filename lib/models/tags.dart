import 'dart:convert' show json;

class AutoWords {
  List<Tags> tags;

  AutoWords({
    this.tags,
  });

  factory AutoWords.fromJson(jsonRes) {
    if (jsonRes == null) return null;
    List<Tags> tags = jsonRes['tags'] is List ? [] : null;
    if (tags != null) {
      for (var item in jsonRes['tags']) {
        if (item != null) {
          tags.add(Tags.fromJson(item));
        }
      }
    }

    return AutoWords(
      tags: tags,
    );
  }
  Map<String, dynamic> toJson() => {
        'tags': tags,
      };

  @override
  String toString() {
    return json.encode(this);
  }
}

class Tags {
  String name;
  String translated_name;

  Tags({
    this.name,
    this.translated_name,
  });

  factory Tags.fromJson(jsonRes) => jsonRes == null
      ? null
      : Tags(
          name: jsonRes['name'],
          translated_name: jsonRes['translated_name'],
        );
  Map<String, dynamic> toJson() => {
        'name': name,
        'translated_name': translated_name,
      };

  @override
  String toString() {
    return json.encode(this);
  }
}
