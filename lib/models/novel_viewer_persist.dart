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
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';

part 'novel_viewer_persist.g.dart';

@JsonSerializable()
class NovelViewerPersist {
  int? id;
  @JsonKey(name: 'novel_id')
  int novelId;
  double offset;

  NovelViewerPersist({this.id, required this.novelId, required this.offset});

  factory NovelViewerPersist.fromJson(Map<String, dynamic> json) =>
      _$NovelViewerPersistFromJson(json);

  Map<String, dynamic> toJson() => _$NovelViewerPersistToJson(this);
}

final String tableNovelViewerPersist = 'NovelViewerPersist';
final String cid = "id";
final String cNovel_id = "novel_id";
final String cOffset = "offset";
final String cBook = "book";

class NovelViewerPersistProvider {
  late Database db;

  Future open() async {
    String databasesPath = (await getDatabasesPath());
    String path = join(databasesPath, 'NovelViewerPersist.db');
    db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute('''
create table $tableNovelViewerPersist ( 
  $cid integer primary key autoincrement, 
  $cNovel_id integer not null,
  $cOffset REAL NOT NULL
  )
''');
    });
  }

  Future<NovelViewerPersist> insert(NovelViewerPersist todo) async {
    final result = await getNovelPersistById(todo.novelId);
    if (result != null) {
      todo.id = result.id;
    }
    todo.id = await db.insert(tableNovelViewerPersist, todo.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return todo;
  }

  Future<NovelViewerPersist?> getNovelPersistById(int Novel_id) async {
    List<Map<String, dynamic>> maps = await db.query(tableNovelViewerPersist,
        columns: [
          cid,
          cNovel_id,
          cOffset,
        ],
        where: '$cNovel_id = ?',
        whereArgs: [Novel_id]);
    if (maps.length > 0) {
      return NovelViewerPersist.fromJson(maps.first);
    }
    return null;
  }

  Future<List<NovelViewerPersist>> getAll() async {
    List<NovelViewerPersist> result = [];
    List<Map<String, dynamic>> maps = await db.query(
      tableNovelViewerPersist,
      columns: [cid, cNovel_id, cOffset],
    );

    if (maps.length > 0) {
      maps.forEach((f) {
        result.add(NovelViewerPersist.fromJson(f));
      });
    }
    return result;
  }

  Future<int> delete(int id) async {
    return await db.delete(tableNovelViewerPersist,
        where: '$cNovel_id = ?', whereArgs: [id]);
  }

  Future<int> update(NovelViewerPersist todo) async {
    return await db.update(tableNovelViewerPersist, todo.toJson(),
        where: '$cid = ?', whereArgs: [todo.id]);
  }

  Future close() async => db.close();

  Future deleteAll() async {
    return await db.delete(tableNovelViewerPersist);
  }
}
