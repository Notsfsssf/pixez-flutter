import 'dart:convert' show json;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

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

class TagsPersist {
  int id;
  String name;
  String translatedName;
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      columnId: id,
      columnName: name,
      columnTranslatedName: translatedName
    };
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }

  TagsPersist.fromMap(Map<String, dynamic> map) {
    id = map[columnId];
    name = map[columnName];
    translatedName = map[columnTranslatedName];
  }
}

final String tableTag = 'tag';
final String columnId = '_id';
final String columnName = 'name';
final String columnTranslatedName = 'translated_name';

class TagsPersistProvider {
  Database db;

  Future open() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'demo.db');
    db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute('''
create table $tableTag ( 
  $columnId integer primary key autoincrement, 
  $columnName text not null,
  $columnTranslatedName text not null)
''');
    });
  }

  Future<TagsPersist> insert(TagsPersist tag) async {
    tag.id = await db.insert(tableTag, tag.toMap());
    return tag;
  }

  Future<TagsPersist> getTodo(int id) async {
    List<Map> maps = await db.query(tableTag,
        columns: [columnId, columnName, columnTranslatedName],
        where: '$columnId = ?',
        whereArgs: [id]);
    if (maps.length > 0) {
      return TagsPersist.fromMap(maps.first);
    }
    return null;
  }

  Future<List<TagsPersist>> getAllAccount() async {
    List result = new List<TagsPersist>();
    List<Map> maps = await db
        .query(tableTag, columns: [columnId, columnName, columnTranslatedName]);

    if (maps.length > 0) {
      maps.forEach((f) {
        result.add(TagsPersist.fromMap(maps.first));
      });
    }
    return result;
  }

  Future<int> delete(int id) async {
    return await db.delete(tableTag, where: '$columnId = ?', whereArgs: [id]);
  }
  Future<int> deleteAll() async {
    return await db.delete(tableTag);
  }
  Future<int> update(TagsPersist todo) async {
    return await db.update(tableTag, todo.toMap(),
        where: '$columnId = ?', whereArgs: [todo.id]);
  }

  Future close() async => db.close();
}
