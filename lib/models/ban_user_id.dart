import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class BanUserIdPersist {
  String userId;
  int id;
  String name;

  BanUserIdPersist();

  BanUserIdPersist.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json[columnUserId];
    name = json[columnName];
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
  Database db;

  Future open() async {
    String databasesPath = await getDatabasesPath();
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

  Future<BanUserIdPersist> getAccount(int id) async {
    List<Map> maps = await db.query(tableBanUserId,
        columns: [columnId, columnUserId],
        where: '$columnId = ?',
        whereArgs: [id]);
    if (maps.length > 0) {
      return BanUserIdPersist.fromJson(maps.first);
    }
    return null;
  }

  Future<List<BanUserIdPersist>> getAllAccount() async {
    List result = new List<BanUserIdPersist>();
    List<Map> maps = await db
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
}
