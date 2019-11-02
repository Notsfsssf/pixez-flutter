import 'package:json_annotation/json_annotation.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
part 'ban_comment_persist.g.dart';

final String columnId = 'id';
final String columnCommentId= 'comment_id';
final String columnName = 'name';
final String tableBanComment = 'banComment';

@JsonSerializable()
class BanCommentPersist {
  @JsonKey(name: 'comment_id')
  String commentId;
  String name;
  int? id;

  BanCommentPersist({required this.commentId, required this.name, this.id});

  factory BanCommentPersist.fromJson(Map<String, dynamic> json) =>
      _$BanCommentPersistFromJson(json);

  Map<String, dynamic> toJson() => _$BanCommentPersistToJson(this);
}

class BanCommenProvider {
  late Database db;

  Future open() async {
    String databasesPath = (await getDatabasesPath());
    String path = join(databasesPath, 'banncommentid.db');
    db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute('''
create table $tableBanComment ( 
  $columnId integer primary key autoincrement, 
  $columnCommentId text not null,
  $columnName text not null
  )
''');
    });
  }

  Future<BanCommentPersist> insert(BanCommentPersist todo) async {
    todo.id = await db.insert(tableBanComment, todo.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return todo;
  }

  Future<BanCommentPersist?> getAccount(int id) async {
    List<Map<String, dynamic>> maps = await db.query(tableBanComment,
        columns: [columnId, columnCommentId],
        where: '$columnId = ?',
        whereArgs: [id]);
    if (maps.length > 0) {
      return BanCommentPersist.fromJson(maps.first);
    }
    return null;
  }

  Future<List<BanCommentPersist>> getAllAccount() async {
    List<BanCommentPersist> result = [];
    List<Map<String, dynamic>> maps = await db.query(tableBanComment,
        columns: [columnId, columnCommentId, columnName]);

    if (maps.length > 0) {
      maps.forEach((f) {
        result.add(BanCommentPersist.fromJson(f));
      });
    }
    return result;
  }

  Future<int> delete(int id) async {
    return await db
        .delete(tableBanComment, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> deleteAll() async {
    return await db.delete(tableBanComment);
  }

  Future<int> update(BanCommentPersist todo) async {
    return await db.update(tableBanComment, todo.toJson(),
        where: '$columnId = ?', whereArgs: [todo.id]);
  }

  Future close() async => db.close();
}
