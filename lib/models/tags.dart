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
import 'dart:convert' show json;

import 'package:json_annotation/json_annotation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

part 'tags.g.dart';

class AutoWords {
  List<Tags> tags;

  AutoWords({
    required this.tags,
  });

  factory AutoWords.fromJson(jsonRes) {
    List<Tags> tags = [];
    for (var item in jsonRes['tags']) {
      if (item != null) {
        tags.add(Tags.fromJson(item));
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
  String? translated_name;

  Tags({
    required this.name,
    this.translated_name,
  });

  factory Tags.fromJson(jsonRes) => Tags(
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

@JsonSerializable()
class TagsPersist {
  @JsonKey(name: '_id')
  int? id;
  String name;
  @JsonKey(name: 'translated_name')
  String translatedName;

  TagsPersist({this.id, required this.name, required this.translatedName});

  factory TagsPersist.fromJson(Map<String, dynamic> json) =>
      _$TagsPersistFromJson(json);

  Map<String, dynamic> toJson() => _$TagsPersistToJson(this);
}

final String tableTag = 'tag';
final String columnId = '_id';
final String columnName = 'name';
final String columnTranslatedName = 'translated_name';

class TagsPersistProvider {
  late Database db;

  Future open() async {
    String databasesPath = (await getDatabasesPath())!;
    String path = join(databasesPath, '${tableTag}.db');
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
    tag.id = await db.insert(tableTag, tag.toJson());
    return tag;
  }

  Future<TagsPersist?> getTodo(int id) async {
    List<Map<String, dynamic>> maps = await db.query(tableTag,
        columns: [columnId, columnName, columnTranslatedName],
        where: '$columnId = ?',
        whereArgs: [id]);
    if (maps.length > 0) {
      return TagsPersist.fromJson(maps.first);
    }
    return null;
  }

  Future<List<TagsPersist>> getAllAccount() async {
    List<TagsPersist> result = [];
    List<Map<String, dynamic>> maps = await db
        .query(tableTag, columns: [columnId, columnName, columnTranslatedName]);

    if (maps.length > 0) {
      maps.forEach((f) {
        result.add(TagsPersist.fromJson(f));
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
    return await db.update(tableTag, todo.toJson(),
        where: '$columnId = ?', whereArgs: [todo.id]);
  }

  Future close() async => db.close();
}
