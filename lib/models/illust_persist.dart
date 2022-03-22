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

import 'package:json_annotation/json_annotation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

part 'illust_persist.g.dart';

@JsonSerializable()
class IllustPersist {
  int? id;
  @JsonKey(name: 'illust_id')
  int illustId;
  @JsonKey(name: 'user_id')
  int userId;
  @JsonKey(name: 'picture_url')
  String pictureUrl;
  @JsonKey(name: 'user_name')
  String? userName;
  @JsonKey(name: "title")
  String? title;
  int time;

  IllustPersist(
      {this.id,
      required this.illustId,
      required this.userId,
      required this.pictureUrl,
      required this.time,
      required this.title,
      required this.userName});

  factory IllustPersist.fromJson(Map<String, dynamic> json) =>
      _$IllustPersistFromJson(json);

  Map<String, dynamic> toJson() => _$IllustPersistToJson(this);
}

final String tableIllustPersist = 'illustpersist';
final String cid = "id";
final String cillust_id = "illust_id";
final String cuser_id = "user_id";
final String cpicture_url = "picture_url";
final String ctitle = "title";
final String cuser_name = "user_name";
final String ctime = "time";

class IllustPersistProvider {
  late Database db;

  void _createTableV2(Batch batch) {
    batch.execute('DROP TABLE IF EXISTS $tableIllustPersist');
    db.execute('''
create table $tableIllustPersist ( 
  $cid integer primary key autoincrement, 
  $cillust_id integer not null,
  $cuser_id integer not null,
  $cpicture_url text not null,
  $ctitle text,
  $cuser_name text,
    $ctime integer not null
  )
''');
  }

  void _updateTableV1ToV2(Batch batch) {
    batch.execute(
        '''
        ALTER TABLE $tableIllustPersist ADD $ctitle TEXT;
            ''');
  }

  Future open() async {
    String databasesPath = (await getDatabasesPath());
    String path = join(databasesPath, 'illustpersist.db');
    db = await openDatabase(
      path,
      version: 2,
      onCreate: (Database db, int version) async {
        var batch = db.batch();
        _createTableV2(batch);
        await batch.commit();
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        var batch = db.batch();
        if (oldVersion < 2) {
          _updateTableV1ToV2(batch);
        }
        await batch.commit();
      },
    );
  }

  Future<IllustPersist> insert(IllustPersist todo) async {
    final result = await getAccount(todo.illustId);
    if (result != null) {
      todo.id = result.id;
    }
    todo.id = await db.insert(tableIllustPersist, todo.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return todo;
  }

  Future<IllustPersist?> getAccount(int illust_id) async {
    List<Map<String, dynamic>> maps = await db.query(tableIllustPersist,
        columns: [cid, cillust_id, cuser_id, cpicture_url, ctime],
        where: '$cillust_id = ?',
        whereArgs: [illust_id]);
    if (maps.length > 0) {
      return IllustPersist.fromJson(maps.first);
    }
    return null;
  }

  Future<List<IllustPersist>> getAllAccount() async {
    List<IllustPersist> result = [];
    List<Map<String, dynamic>> maps = await db.query(tableIllustPersist,
        columns: [cid, cillust_id, cuser_id, cpicture_url, ctime, cuser_name, ctitle],
        orderBy: ctime);

    if (maps.length > 0) {
      maps.forEach((f) {
        result.add(IllustPersist.fromJson(f));
      });
    }
    return result;
  }

  Future<int> delete(int id) async {
    return await db
        .delete(tableIllustPersist, where: '$cillust_id = ?', whereArgs: [id]);
  }

  Future<int> update(IllustPersist todo) async {
    return await db.update(tableIllustPersist, todo.toJson(),
        where: '$cid = ?', whereArgs: [todo.id]);
  }

  Future close() async => db.close();

  Future deleteAll() async {
    return await db.delete(tableIllustPersist);
  }
}
