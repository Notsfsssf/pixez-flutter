import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class IllustPersist {
  int id;
  int illustId;
  int userId;
  String pictureUrl;

  IllustPersist.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    illustId = json['illust_id'];
    userId = json['user_id'];
    pictureUrl = json['picture_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['illust_id'] = this.illustId;
    data['user_id'] = this.userId;
    data['picture_url'] = this.pictureUrl;
    return data;
  }
}

final String tableIllustPersist = 'illustpersist';
final String cid = "id";
final String cillust_id = "illust_id";
final String cuser_id = "illust_id";
final String cpicture_url = "picture_url";

class IllustPersistProvider {
  Database db;

  Future open() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'illustpersist.db');
    db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute('''
create table $tableIllustPersist ( 
  id integer primary key autoincrement, 
  illust_id integer not null,
  user_id integer not null,
  picture_url text not null
  )
''');
    });
  }

  Future<IllustPersist> insert(IllustPersist todo) async {
    todo.id = await db.insert('illustpersist', todo.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return todo;
  }

  Future<IllustPersist> getAccount(int id) async {
    List<Map> maps = await db.query(tableIllustPersist,
        columns: [cid, cillust_id, cuser_id, cpicture_url],
        where: '$cid = ?',
        whereArgs: [id]);
    if (maps.length > 0) {
      return IllustPersist.fromJson(maps.first);
    }
    return null;
  }

  Future<List<IllustPersist>> getAllAccount() async {
    List result = new List<IllustPersist>();
    List<Map> maps = await db.query(tableIllustPersist, columns: [cid, cillust_id, cuser_id, cpicture_url]);

    if (maps.length > 0) {
      maps.forEach((f) {
        result.add(IllustPersist.fromJson(f));
      });
    }
    return result;
  }

  Future<int> delete(int id) async {
    return await db
        .delete(tableIllustPersist, where: '$cid = ?', whereArgs: [id]);
  }

  Future<int> update(IllustPersist todo) async {
    return await db.update(tableIllustPersist, todo.toJson(),
        where: '$cid = ?', whereArgs: [todo.id]);
  }

  Future close() async => db.close();
}
