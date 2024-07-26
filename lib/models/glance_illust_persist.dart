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

import 'dart:async';
import 'dart:io';
import 'package:path/path.dart' as Path;

import 'package:json_annotation/json_annotation.dart';
import 'package:path/path.dart';
import 'package:pixez/models/illust.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path_provider_foundation/path_provider_foundation.dart';

part 'glance_illust_persist.g.dart';

extension ListGlanceIllustExt on Iterable<Illusts> {
  List<GlanceIllustPersist> toGlancePersist(String type, int time) {
    return map((e) => e.toGlanceIllustPersist(type, time)).toList();
  }
}

extension GlanceIllustExt on Illusts {
  GlanceIllustPersist toGlanceIllustPersist(String type, int time) {
    return GlanceIllustPersist(
        illustId: id,
        userId: user.id,
        pictureUrl: imageUrls.medium,
        originalUrl: metaSinglePage?.originalImageUrl ??
            metaPages.firstOrNull?.imageUrls?.original,
        largeUrl: imageUrls.large,
        title: title,
        userName: user.name,
        time: time,
        type: type);
  }
}

@JsonSerializable()
class GlanceIllustPersist {
  int? id;
  @JsonKey(name: 'illust_id')
  int illustId;
  @JsonKey(name: 'user_id')
  int userId;
  @JsonKey(name: 'picture_url')
  String pictureUrl;
  @JsonKey(name: 'original_url')
  String? originalUrl;
  @JsonKey(name: 'large_url')
  String? largeUrl;
  @JsonKey(name: 'user_name')
  String? userName;
  @JsonKey(name: "title")
  String? title;
  @JsonKey(name: "type")
  String type;
  int time;

  GlanceIllustPersist(
      {this.id,
      required this.illustId,
      required this.userId,
      required this.pictureUrl,
      required this.originalUrl,
      required this.largeUrl,
      required this.time,
      required this.title,
      required this.userName,
      required this.type});

  factory GlanceIllustPersist.fromJson(Map<String, dynamic> json) =>
      _$GlanceIllustPersistFromJson(json);

  Map<String, dynamic> toJson() => _$GlanceIllustPersistToJson(this);
}

final String tableIllustPersist = 'glanceillustpersist';
final String cid = "id";
final String cillust_id = "illust_id";
final String cuser_id = "user_id";
final String cpicture_url = "picture_url";
final String clarge_url = "large_url";
final String coriginal_url = "original_url";
final String ctitle = "title";
final String cuser_name = "user_name";
final String ctime = "time";
final String ctype = "type";

class GlanceIllustPersistProvider {
  late Database db;

  void _createTableV2(Batch batch) {
    batch.execute('''
create table $tableIllustPersist ( 
  $cid integer primary key autoincrement, 
  $cillust_id integer not null,
  $cuser_id integer not null,
  $cpicture_url text not null,
  $ctype text not null,
  $ctitle text,
  $clarge_url text,
  $coriginal_url text,
  $cuser_name text,
    $ctime integer not null
  )
''');
  }

  Future<String> getPath() async {
    if (Platform.isIOS) {
      try {
        final PathProviderFoundation providerFoundation =
            PathProviderFoundation();
        final path = await providerFoundation.getContainerPath(
            appGroupIdentifier: "group.pixez");
        final directory = Directory(Path.join(path!, "DB"));
        if (!(await directory.exists())) {
          await directory.create(recursive: true);
        }
        return directory.path;
      } catch (e) {}
    }
    return await getDatabasesPath();
  }

  Future open() async {
    String databasesPath = (await getPath());
    String path = join(databasesPath, 'glanceillustpersist.db');
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

  void _updateTableV1ToV2(Batch batch) {
    batch.execute('''
        ALTER TABLE $tableIllustPersist ADD $coriginal_url TEXT;
            ''');
    batch.execute('''
        ALTER TABLE $tableIllustPersist ADD $clarge_url TEXT;
    ''');
  }

  Future<GlanceIllustPersist> insert(GlanceIllustPersist todo) async {
    final result = await getAccount(todo.illustId);
    if (result != null) {
      todo.id = result.id;
    }
    todo.id = await db.insert(tableIllustPersist, todo.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return todo;
  }

  Future<int> insertAll(List<GlanceIllustPersist> todo) async {
    final batch = db.batch();
    for (var i in todo) {
      batch.insert(tableIllustPersist, i.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    batch.commit();
    return 0;
  }

  Future<GlanceIllustPersist?> getAccount(int illust_id) async {
    List<Map<String, dynamic>> maps = await db.query(tableIllustPersist,
        columns: [cid, cillust_id, cuser_id, cpicture_url, ctime, ctype],
        where: '$cillust_id = ?',
        whereArgs: [illust_id]);
    if (maps.length > 0) {
      return GlanceIllustPersist.fromJson(maps.first);
    }
    return null;
  }

  Future<List<GlanceIllustPersist>> getLikeIllusts(String type) async {
    List<GlanceIllustPersist> result = [];
    List<Map<String, dynamic>> maps = await db.query(tableIllustPersist,
        columns: [
          cid,
          cillust_id,
          cuser_id,
          cpicture_url,
          ctime,
          ctype,
          cuser_name,
          ctitle
        ],
        where: '$ctype = ?',
        whereArgs: ["${type}"],
        orderBy: ctime);

    if (maps.length > 0) {
      maps.forEach((f) {
        result.add(GlanceIllustPersist.fromJson(f));
      });
    }
    return result;
  }

  Future<List<GlanceIllustPersist>> getAllAccount() async {
    List<GlanceIllustPersist> result = [];
    List<Map<String, dynamic>> maps = await db.query(tableIllustPersist,
        columns: [
          cid,
          cillust_id,
          cuser_id,
          cpicture_url,
          ctime,
          ctype,
          cuser_name,
          ctitle
        ],
        orderBy: ctime);

    if (maps.length > 0) {
      maps.forEach((f) {
        result.add(GlanceIllustPersist.fromJson(f));
      });
    }
    return result;
  }

  Future<int> delete(int id) async {
    return await db
        .delete(tableIllustPersist, where: '$cillust_id = ?', whereArgs: [id]);
  }

  Future<int> update(GlanceIllustPersist todo) async {
    return await db.update(tableIllustPersist, todo.toJson(),
        where: '$cid = ?', whereArgs: [todo.id]);
  }

  Future close() async => db.close();

  Future deleteAll() async {
    return await db.delete(tableIllustPersist);
  }
}
