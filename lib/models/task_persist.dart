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
import 'package:pixez/models/illust.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class TaskPersist {
  int? id;
  String userName;
  String fileName;
  String title;
  String url;
  String? medium;
  int userId;
  int illustId;
  int sanityLevel;
  int status;

  TaskPersist(
      {required this.userName,
      required this.title,
      required this.url,
      required this.userId,
      required this.illustId,
      required this.fileName,
      this.sanityLevel = 0,
      this.id,
      this.medium,
      required this.status});

  factory TaskPersist.fromJson(Map<String, dynamic> json) {
    return TaskPersist(
        id: json[columnId],
        userName: json[columnUserName],
        title: json[columnTitle],
        url: json[columnUrl],
        userId: json[columnUserId],
        sanityLevel: json[columnSanityLevel],
        illustId: json[columnIllustId],
        status: json[columnStatus],
        fileName: json[columnFileName],
        medium: json[columnMedium]);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data[columnId] = this.id;
    data[columnUrl] = this.url;
    data[columnTitle] = this.title;
    data[columnUserName] = this.userName;
    data[columnIllustId] = this.illustId;
    data[columnSanityLevel] = this.sanityLevel;
    data[columnUserId] = this.userId;
    data[columnStatus] = this.status;
    data[columnFileName] = this.fileName;
    return data;
  }

  Illusts toIllusts() {
    var user2 = User(
        id: this.userId,
        name: this.userName,
        account: '',
        profileImageUrls: ProfileImageUrls(medium: ''),
        comment: "",
        isFollowed: false);
    var illusts = Illusts(
        id: this.illustId,
        title: this.title,
        type: 'type',
        imageUrls:
            ImageUrls(squareMedium: '', medium: this.medium ?? '', large: ''),
        caption: 'caption',
        restrict: 0,
        user: user2,
        tags: [],
        tools: [],
        createDate: '',
        pageCount: 0,
        width: 0,
        height: 0,
        sanityLevel: this.sanityLevel,
        xRestrict: 0,
        series: null,
        metaSinglePage: MetaSinglePage(originalImageUrl: ''),
        metaPages: [],
        totalView: 0,
        totalBookmarks: 0,
        totalComments: 0,
        isBookmarked: false,
        visible: false,
        isMuted: false,
        illustAIType: 1);
    illusts.user = user2;
    illusts.title = this.title;
    illusts.id = this.illustId;
    return illusts;
  }
}

final String tableAccount = 'task';
final String columnId = 'id';
final String columnUrl = 'url';
final String columnTitle = 'title';
final String columnUserName = 'user_name';
final String columnIllustId = 'illust_id';
final String columnUserId = 'user_id';
final String columnStatus = 'status';
final String columnFileName = 'file_name';
final String columnMedium = 'medium';
final String columnSanityLevel = 'sanity_level';

class TaskPersistProvider {
  late Database db;

  Future open() async {
    String databasesPath = (await getDatabasesPath());
    String path =
        join(databasesPath, 'task1.db'); //某个版本出的bug，升级table无法定位问题，只能改了
    db = await openDatabase(path, version: 2,
        onCreate: (Database db, int version) async {
      await db.execute('''
create table $tableAccount ( 
  $columnId integer primary key autoincrement, 
  $columnTitle text not null,
  $columnUserName text not null,
  $columnUrl text not null,
  $columnSanityLevel integer,
  $columnIllustId integer not null,
  $columnUserId integer not null,
  $columnStatus integer not null,
  $columnFileName text not null,
  $columnMedium text
  )
''');
    }, onUpgrade: (Database db, int oldVersion, int newVersion) async {
      if (oldVersion == 1 && newVersion == 2) {
        await db.execute('''
        ALTER TABLE $tableAccount
  ADD $columnMedium text;
        ''');
      }
    });
  }

  Future<TaskPersist> insert(TaskPersist todo) async {
    todo.id = await db.insert(tableAccount, todo.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return todo;
  }

  Future<TaskPersist?> getAccount(String id) async {
    List<Map<String, dynamic>> maps = await db.query(tableAccount,
        columns: [
          columnId,
          columnUserId,
          columnIllustId,
          columnFileName,
          columnTitle,
          columnSanityLevel,
          columnUserName,
          columnUrl,
          columnStatus,
          columnMedium
        ],
        where: '$columnUrl = ?',
        whereArgs: [id]);
    if (maps.length > 0) {
      return TaskPersist.fromJson(maps.first);
    }
    return null;
  }

  Future<int> remove(int id) async {
    final result =
        await db.delete(tableAccount, where: '$columnId = ?', whereArgs: [id]);
    return result;
  }

  Future<int> deleteAll() async {
    final result = await db.delete(tableAccount);
    return result;
  }

  Future<int> update(TaskPersist todo) async {
    final result = await db.update(tableAccount, todo.toJson(),
        where: '$columnId = ?', whereArgs: [todo.id]);
    return result;
  }

  Future<List<TaskPersist>> getAllAccount() async {
    List<Map<String, dynamic>> maps = await db.query(
      tableAccount,
      columns: [
        columnId,
        columnUserId,
        columnIllustId,
        columnTitle,
        columnUserName,
        columnUrl,
        columnFileName,
        columnSanityLevel,
        columnStatus,
        columnMedium
      ],
      orderBy: "${columnId} ASC",
    );
    var list = maps.map((e) => TaskPersist.fromJson(e)).toList();
    return list;
  }

  Future<List<TaskPersist>> getDownloadTask(
      int page, int status, bool asc) async {
    final LIMIT = 16;
    List<Map<String, dynamic>> maps = await db.query(
      tableAccount,
      columns: [
        columnId,
        columnUserId,
        columnIllustId,
        columnTitle,
        columnUserName,
        columnUrl,
        columnFileName,
        columnSanityLevel,
        columnStatus,
        columnMedium
      ],
      orderBy: "${columnId} ${asc ? "ASC" : "DESC"}",
      limit: LIMIT,
      offset: (page - 1) * LIMIT,
      where: status == 10 ? null : '$columnStatus = ?',
      whereArgs: status == 10 ? null : [status],
    );
    var list = maps.map((e) => TaskPersist.fromJson(e)).toList();
    return list;
  }
}
