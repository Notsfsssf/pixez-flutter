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
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class BanUserIdPersist {
  String? userId;
  int? id;
  String? name;

  BanUserIdPersist({this.userId, this.name, this.id});

  factory BanUserIdPersist.fromJson(Map<String, dynamic> json) {
    return BanUserIdPersist(
        userId: json[columnUserId], name: json[columnName], id: json[columnId]);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data[columnUserId] = this.userId;
    data[columnName] = this.name;
    return data;
  }
}

final String columnId = 'id';
final String columnUserId = 'user_id';
final String columnName = 'name';

final String tableBanUserId = 'banuserid';

class BanUserIdProvider {
  late Database db;

  Future open() async {
    String databasesPath = (await getDatabasesPath());
    String path = join(databasesPath, 'banuserid.db');
    db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute('''
create table $tableBanUserId ( 
  $columnId integer primary key autoincrement, 
  $columnUserId text not null,
  $columnName text not null
  )
''');
    });
  }

  Future<BanUserIdPersist> insert(BanUserIdPersist todo) async {
    todo.id = await db.insert(tableBanUserId, todo.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return todo;
  }

  Future<BanUserIdPersist?> getAccount(int id) async {
    List<Map<String, dynamic>> maps = await db.query(tableBanUserId,
        columns: [columnId, columnUserId],
        where: '$columnId = ?',
        whereArgs: [id]);
    if (maps.length > 0) {
      return BanUserIdPersist.fromJson(maps.first);
    }
    return null;
  }

  Future<List<BanUserIdPersist>> getAllAccount() async {
    List<BanUserIdPersist> result = [];
    List<Map<String, dynamic>> maps = await db
        .query(tableBanUserId, columns: [columnId, columnUserId, columnName]);

    if (maps.length > 0) {
      maps.forEach((f) {
        result.add(BanUserIdPersist.fromJson(f));
      });
    }
    return result;
  }

  Future<int> delete(int id) async {
    return await db
        .delete(tableBanUserId, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> deleteAll() async {
    return await db.delete(tableBanUserId);
  }

  Future<int> update(BanUserIdPersist todo) async {
    return await db.update(tableBanUserId, todo.toJson(),
        where: '$columnId = ?', whereArgs: [todo.id]);
  }

  Future close() async => db.close();

  Future<List<BanUserIdPersist>> insertAll(
      List<BanUserIdPersist> list) async {
    await db.transaction((txn) async {
      for (var todo in list) {
        todo.id = await txn.insert(tableBanUserId, todo.toJson(),
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
    return list;
  }
}
