import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class IllustPersist {
  IllustPersist();

  int id;
  int illustId;
  int userId;
  String pictureUrl;
  int time;

  IllustPersist.fromJson(Map<String, dynamic> json) {
    id = json[cid];
    illustId = json[cillust_id];
    userId = json[cuser_id];
    pictureUrl = json[cpicture_url];
    time = json[ctime];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data[cid] = this.id;
    data[cillust_id] = this.illustId;
    data[cuser_id] = this.userId;
    data[cpicture_url] = this.pictureUrl;
    data[ctime] = this.time;
    return data;
  }
}

final String tableIllustPersist = 'illustpersist';
final String cid = "id";
final String cillust_id = "illust_id";
final String cuser_id = "user_id";
final String cpicture_url = "picture_url";
final String ctime = "time";

class IllustPersistProvider {
  Database db;

  Future open() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'illustpersist.db');
    db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute('''
create table $tableIllustPersist ( 
  $cid integer primary key autoincrement, 
  $cillust_id integer not null,
  $cuser_id integer not null,
  $cpicture_url text not null,
    $ctime integer not null
  )
''');
    });
  }

  Future<IllustPersist> insert(IllustPersist todo) async {
    print(todo.toJson());
    final result = await getAccount(todo.illustId);
    if (result != null) {
      todo.id = result.id;
    }
    todo.id = await db.insert(tableIllustPersist, todo.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return todo;
  }

  Future<IllustPersist> getAccount(int illust_id) async {
    List<Map> maps = await db.query(tableIllustPersist,
        columns: [cid, cillust_id, cuser_id, cpicture_url, ctime],
        where: '$cillust_id = ?',
        whereArgs: [illust_id]);
    if (maps.length > 0) {
      return IllustPersist.fromJson(maps.first);
    }
    return null;
  }

  Future<List<IllustPersist>> getAllAccount() async {
    List result = new List<IllustPersist>();
    List<Map> maps = await db.query(tableIllustPersist,
        columns: [cid, cillust_id, cuser_id, cpicture_url, ctime]);

    if (maps.length > 0) {
      maps.forEach((f) {
        result.add(IllustPersist.fromJson(f));
      });
    }
    return result;
  }

  Future<int> delete(int id) async {
    return await db
        .delete(tableIllustPersist, where: '$cillust_id = ?', whereArgs: [id]);
  }

  Future<int> update(IllustPersist todo) async {
    return await db.update(tableIllustPersist, todo.toJson(),
        where: '$cid = ?', whereArgs: [todo.id]);
  }

  Future close() async => db.close();

  Future deleteAll() async {
    return await db.delete(tableIllustPersist);
  }
}
