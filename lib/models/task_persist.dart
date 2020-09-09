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
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class TaskPersist {
  int id;
  String userName;
  String title;
  String url;
  int userId;
  int illustId;

  TaskPersist.fromJson(Map<String, dynamic> json) {
    id = json[columnId];
    userName = json[columnUserName];
    title = json[columnTitle];
    url = json[columnUrl];
    userId = json[columnUserId];
    illustId = json[columnIllustId];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data[columnId] = this.id;
    data[columnUrl] = this.url;
    data[columnTitle] = this.title;
    data[columnUserName] = this.userName;
    data[columnIllustId] = this.illustId;
    data[columnUserId] = this.userId;
    return data;
  }
}

final String tableAccount = 'account';
final String columnId = 'id';
final String columnUrl = 'url';
final String columnTitle = 'title';
final String columnUserName = 'user_name';
final String columnIllustId = 'illust_id';
final String columnUserId = 'user_id';

class TaskPersistProvider {
  Database db;

  Future open() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'account.db');
    db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute('''
create table $tableAccount ( 
  $columnId integer primary key autoincrement, 
  $columnTitle text not null,
  $columnUserName text not null,
  $columnUrl text not null,
  $columnIllustId integer not null,
  $columnUserId integer not null,
  )
''');
    });
  }

  Future<TaskPersist> insert(TaskPersist todo) async {
    todo.id = await db.insert(tableAccount, todo.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return todo;
  }

  Future<TaskPersist> getAccount(int id) async {
    List<Map> maps = await db.query(tableAccount,
        columns: [
          columnId,
          columnUserId,
          columnIllustId,
          columnTitle,
          columnUserName,
          columnUrl
        ],
        where: '$columnId = ?',
        whereArgs: [id]);
    if (maps.length > 0) {
      return TaskPersist.fromJson(maps.first);
    }
    return null;
  }

  Future<List<TaskPersist>> getAllAccount() async {
    List result = new List<TaskPersist>();
    List<Map> maps = await db.query(tableAccount, columns: [
      columnId,
      columnUserId,
      columnIllustId,
      columnTitle,
      columnUserName,
      columnUrl
    ]);

    if (maps.length > 0) {
      maps.forEach((f) {
        result.add(TaskPersist.fromJson(f));
      });
    }
    return result;
  }
}
