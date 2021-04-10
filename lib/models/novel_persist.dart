/*
 * Copyright (C) 2020. by perol_notsf, All rights reserved
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful, but WITHOUT ANY
 *  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 *  FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License along with
 *  this program. If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:json_annotation/json_annotation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

part 'novel_persist.g.dart';

@JsonSerializable()
class NovelPersist {
  int id;
  @JsonKey(name: 'novel_id')
  int novelId;
  @JsonKey(name: 'user_id')
  int userId;
  @JsonKey(name: 'picture_url')
  String pictureUrl;
  int time;
  String title;
  @JsonKey(name: 'user_name')
  String userName;

  NovelPersist(
      {required this.id,
      required this.novelId,
      required this.userId,
      required this.pictureUrl,
      required this.time,
      required this.title,
      required this.userName});

  factory NovelPersist.fromJson(Map<String, dynamic> json) =>
      _$NovelPersistFromJson(json);

  Map<String, dynamic> toJson() => _$NovelPersistToJson(this);
}

final String tableNovelPersist = 'Novelpersist';
final String cid = "id";
final String cNovel_id = "novel_id";
final String cuser_id = "user_id";
final String cpicture_url = "picture_url";
final String ctime = "time";
final String ctitle = "title";
final String cuserName = "user_name";

class NovelPersistProvider {
  late Database db;

  Future open() async {
    String databasesPath = (await getDatabasesPath());
    String path = join(databasesPath, 'Novelpersist.db');
    db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute('''
create table $tableNovelPersist ( 
  $cid integer primary key autoincrement, 
  $cNovel_id integer not null,
  $cuser_id integer not null,
  $cpicture_url text not null,
  $ctitle text not null,
  $cuserName text not null,
  $ctime integer not null
  )
''');
    });
  }

  Future<NovelPersist> insert(NovelPersist todo) async {
    final result = await getAccount(todo.novelId);
    if (result != null) {
      todo.id = result.id;
    }
    todo.id = await db.insert(tableNovelPersist, todo.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return todo;
  }

  Future<NovelPersist?> getAccount(int Novel_id) async {
    List<Map<String, dynamic>> maps = await db.query(tableNovelPersist,
        columns: [
          cid,
          cNovel_id,
          cuser_id,
          cpicture_url,
          ctime,
          ctitle,
          cuserName
        ],
        where: '$cNovel_id = ?',
        whereArgs: [Novel_id]);
    if (maps.length > 0) {
      return NovelPersist.fromJson(maps.first);
    }
    return null;
  }

  Future<List<NovelPersist>> getAllAccount() async {
    List<NovelPersist> result = [];
    List<Map<String, dynamic>> maps = await db.query(tableNovelPersist,
        columns: [
          cid,
          cNovel_id,
          cuser_id,
          cpicture_url,
          ctime,
          ctitle,
          cuserName
        ],
        orderBy: "$ctime DESC");

    if (maps.length > 0) {
      maps.forEach((f) {
        result.add(NovelPersist.fromJson(f));
      });
    }
    return result;
  }

  Future<int> delete(int id) async {
    return await db
        .delete(tableNovelPersist, where: '$cNovel_id = ?', whereArgs: [id]);
  }

  Future<int> update(NovelPersist todo) async {
    return await db.update(tableNovelPersist, todo.toJson(),
        where: '$cid = ?', whereArgs: [todo.id]);
  }

  Future close() async => db.close();

  Future deleteAll() async {
    return await db.delete(tableNovelPersist);
  }
}
