import 'dart:convert';

import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class NovelTaskPersist {
  int? id;
  int seriesId;
  String seriesTitle;
  String userName;
  String? coverUrl;
  String novelIds;
  int novelCount;
  int doneCount;
  int status;
  String? fileName;

  NovelTaskPersist(
      {required this.seriesId,
      required this.seriesTitle,
      required this.userName,
      required this.novelIds,
      required this.novelCount,
      this.doneCount = 0,
      required this.status,
      this.id,
      this.coverUrl,
      this.fileName});

  factory NovelTaskPersist.fromJson(Map<String, dynamic> json) {
    return NovelTaskPersist(
        id: json[columnNovelTaskId],
        seriesId: json[columnSeriesId],
        seriesTitle: json[columnSeriesTitle],
        userName: json[columnNovelTaskUserName],
        coverUrl: json[columnCoverUrl],
        novelIds: json[columnNovelIds],
        novelCount: json[columnNovelCount],
        doneCount: json[columnDoneCount],
        status: json[columnNovelTaskStatus],
        fileName: json[columnNovelTaskFileName]);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data[columnNovelTaskId] = this.id;
    data[columnSeriesId] = this.seriesId;
    data[columnSeriesTitle] = this.seriesTitle;
    data[columnNovelTaskUserName] = this.userName;
    data[columnCoverUrl] = this.coverUrl;
    data[columnNovelIds] = this.novelIds;
    data[columnNovelCount] = this.novelCount;
    data[columnDoneCount] = this.doneCount;
    data[columnNovelTaskStatus] = this.status;
    data[columnNovelTaskFileName] = this.fileName;
    return data;
  }

  List<int> getNovelIds() {
    try {
      final list = jsonDecode(novelIds) as List<dynamic>;
      return list.map((e) => e as int).toList();
    } catch (e) {
      print(e);
      return [];
    }
  }
}

final String novelTaskTable = 'novel_task';
final String columnNovelTaskId = 'id';
final String columnSeriesId = 'series_id';
final String columnSeriesTitle = 'series_title';
final String columnNovelTaskUserName = 'user_name';
final String columnCoverUrl = 'cover_url';
final String columnNovelIds = 'novel_ids';
final String columnNovelCount = 'novel_count';
final String columnDoneCount = 'done_count';
final String columnNovelTaskStatus = 'status';
final String columnNovelTaskFileName = 'file_name';

class NovelTaskPersistProvider {
  late Database db;

  Future open() async {
    String databasesPath = (await getDatabasesPath());
    String path = join(databasesPath, 'novel_task1.db');
    db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute('''
        create table $novelTaskTable ( 
          $columnNovelTaskId integer primary key autoincrement, 
          $columnSeriesId integer not null,
          $columnSeriesTitle text not null,
          $columnNovelTaskUserName text not null,
          $columnCoverUrl text,
          $columnNovelIds text not null,
          $columnNovelCount integer not null,
          $columnDoneCount integer not null,
          $columnNovelTaskStatus integer not null,
          $columnNovelTaskFileName text
          )
''');
    });
  }

  Future<NovelTaskPersist> insert(NovelTaskPersist todo) async {
    todo.id = await db.insert(novelTaskTable, todo.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return todo;
  }

  Future<NovelTaskPersist?> getAccount(String id) async {
    List<Map<String, dynamic>> maps = await db.query(novelTaskTable,
        columns: [
          columnNovelTaskId,
          columnSeriesId,
          columnSeriesTitle,
          columnNovelTaskUserName,
          columnCoverUrl,
          columnNovelIds,
          columnNovelCount,
          columnDoneCount,
          columnNovelTaskStatus,
          columnNovelTaskFileName
        ],
        where: '$columnSeriesId = ?',
        whereArgs: [id]);
    if (maps.length > 0) {
      return NovelTaskPersist.fromJson(maps.first);
    }
    return null;
  }

  Future<int> remove(int id) async {
    final result = await db.delete(novelTaskTable,
        where: '$columnNovelTaskId = ?', whereArgs: [id]);
    return result;
  }

  Future<int> deleteAll() async {
    final result = await db.delete(novelTaskTable);
    return result;
  }

  Future<int> update(NovelTaskPersist todo) async {
    final result = await db.update(novelTaskTable, todo.toJson(),
        where: '$columnNovelTaskId = ?', whereArgs: [todo.id]);
    return result;
  }

  Future<List<NovelTaskPersist>> getAllAccount() async {
    List<Map<String, dynamic>> maps = await db.query(
      novelTaskTable,
      columns: [
        columnNovelTaskId,
        columnSeriesId,
        columnSeriesTitle,
        columnNovelTaskUserName,
        columnCoverUrl,
        columnNovelIds,
        columnNovelCount,
        columnDoneCount,
        columnNovelTaskStatus,
        columnNovelTaskFileName
      ],
      orderBy: "${columnNovelTaskId} ASC",
    );
    var list = maps.map((e) => NovelTaskPersist.fromJson(e)).toList();
    return list;
  }

  Future<List<NovelTaskPersist>> getDownloadTask(
      int page, int status, bool asc) async {
    final LIMIT = 16;
    List<Map<String, dynamic>> maps = await db.query(
      novelTaskTable,
      columns: [
        columnNovelTaskId,
        columnSeriesId,
        columnSeriesTitle,
        columnNovelTaskUserName,
        columnCoverUrl,
        columnNovelIds,
        columnNovelCount,
        columnDoneCount,
        columnNovelTaskStatus,
        columnNovelTaskFileName
      ],
      orderBy: "${columnNovelTaskId} ${asc ? "ASC" : "DESC"}",
      limit: LIMIT,
      offset: (page - 1) * LIMIT,
      where: status == 10 ? null : '$columnNovelTaskStatus = ?',
      whereArgs: status == 10 ? null : [status],
    );
    var list = maps.map((e) => NovelTaskPersist.fromJson(e)).toList();
    return list;
  }
}
