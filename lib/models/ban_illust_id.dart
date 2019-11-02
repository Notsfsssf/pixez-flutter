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
part 'ban_illust_id.g.dart';

final String columnId = 'id';
final String columnIllustId = 'illust_id';
final String columnName = 'name';
final String tableBanIllustId = 'banillustid';

@JsonSerializable()
class BanIllustIdPersist {
  @JsonKey(name: 'illust_id')
  String illustId;
  String name;
  int? id;

  BanIllustIdPersist({required this.illustId, required this.name, this.id});

  factory BanIllustIdPersist.fromJson(Map<String, dynamic> json) =>
      _$BanIllustIdPersistFromJson(json);

  Map<String, dynamic> toJson() => _$BanIllustIdPersistToJson(this);
}

class BanIllustIdProvider {
  late Database db;

  Future open() async {
    String databasesPath = (await getDatabasesPath());
    String path = join(databasesPath, 'banillustid.db');
    db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute('''
create table $tableBanIllustId ( 
  $columnId integer primary key autoincrement, 
  $columnIllustId text not null,
  $columnName text not null
  )
''');
    });
  }

  Future<BanIllustIdPersist> insert(BanIllustIdPersist todo) async {
    todo.id = await db.insert(tableBanIllustId, todo.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return todo;
  }

  Future<List<BanIllustIdPersist>> insertAll(
      List<BanIllustIdPersist> todos) async {
    await db.transaction((txn) async {
      for (var todo in todos) {
        todo.id = await txn.insert(tableBanIllustId, todo.toJson(),
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
    return todos;
  }

  Future<BanIllustIdPersist?> getAccount(int id) async {
    List<Map<String, dynamic>> maps = await db.query(tableBanIllustId,
        columns: [columnId, columnIllustId],
        where: '$columnId = ?',
        whereArgs: [id]);
    if (maps.length > 0) {
      return BanIllustIdPersist.fromJson(maps.first);
    }
    return null;
  }

  Future<List<BanIllustIdPersist>> getAllAccount() async {
    List<BanIllustIdPersist> result = [];
    List<Map<String, dynamic>> maps = await db.query(tableBanIllustId,
        columns: [columnId, columnIllustId, columnName]);

    if (maps.length > 0) {
      maps.forEach((f) {
        result.add(BanIllustIdPersist.fromJson(f));
      });
    }
    return result;
  }

  Future<int> delete(int id) async {
    return await db
        .delete(tableBanIllustId, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> deleteAll() async {
    return await db.delete(tableBanIllustId);
  }

  Future<int> update(BanIllustIdPersist todo) async {
    return await db.update(tableBanIllustId, todo.toJson(),
        where: '$columnId = ?', whereArgs: [todo.id]);
  }

  Future close() async => db.close();
}
