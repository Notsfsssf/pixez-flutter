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
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
part 'ban_tag.g.dart';

@JsonSerializable()
class BanTagPersist {
  int? id;
  String name;
  @JsonKey(name: 'translate_name')
  String translateName;

  BanTagPersist({this.id, required this.name, required this.translateName});

  factory BanTagPersist.fromJson(Map<String, dynamic> json) =>
      _$BanTagPersistFromJson(json);
  Map<String, dynamic> toJson() => _$BanTagPersistToJson(this);
}

final String columnId = 'id';
final String columnTranslateName = 'translate_name';
final String columnName = 'name';
final String tableBanTag = 'bantag';

class BanTagProvider {
  late Database db;

  Future open() async {
    String databasesPath = (await getDatabasesPath());
    String path = join(databasesPath, 'bantag.db');
    db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute('''
create table $tableBanTag ( 
  $columnId integer primary key autoincrement, 
  $columnTranslateName text not null,
  $columnName text not null
  )
''');
    });
  }

  Future<BanTagPersist> insert(BanTagPersist todo) async {
    todo.id = await db.insert(tableBanTag, todo.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return todo;
  }

  Future<BanTagPersist?> getAccount(int id) async {
    List<Map<String, dynamic>> maps = await db.query(tableBanTag,
        columns: [columnId, columnTranslateName],
        where: '$columnId = ?',
        whereArgs: [id]);
    if (maps.length > 0) {
      return BanTagPersist.fromJson(maps.first);
    }
    return null;
  }

  Future<List<BanTagPersist>> getAllAccount() async {
    List<BanTagPersist> result = [];
    List<Map<String, dynamic>> maps = await db.query(tableBanTag,
        columns: [columnId, columnTranslateName, columnName]);

    if (maps.length > 0) {
      maps.forEach((f) {
        result.add(BanTagPersist.fromJson(f));
      });
    }
    return result;
  }

  Future<int> delete(int id) async {
    return await db
        .delete(tableBanTag, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> deleteAll() async {
    return await db.delete(tableBanTag);
  }

  Future<int> update(BanTagPersist todo) async {
    return await db.update(tableBanTag, todo.toJson(),
        where: '$columnId = ?', whereArgs: [todo.id]);
  }

  Future close() async => db.close();

  Future<List<BanTagPersist>> insertAll(List<BanTagPersist> list) async {
    await db.transaction((txn) async {
      for (var todo in list) {
        todo.id = await txn.insert(tableBanTag, todo.toJson(),
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
    return list;
  }
}
