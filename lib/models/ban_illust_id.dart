import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class BanIllustIdPersist {
  String illustId;
  String name;
  int id;

  BanIllustIdPersist();

  BanIllustIdPersist.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json[columnName];
    illustId = json[columnIllustId];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data[columnIllustId] = this.illustId;
    data[columnName] = this.name;
    return data;
  }
}

final String columnId = 'id';
final String columnIllustId = 'illust_id';
final String columnName = 'name';

final String tableBanIllustId = 'banillustid';

class BanIllustIdProvider {
  Database db;

  Future open() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'banillustid.db');
    db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute('''
create table $tableBanIllustId ( 
  $columnId integer primary key autoincrement, 
  $columnIllustId text not null,
  $columnName text not null
  )
''');
    });
  }

  Future<BanIllustIdPersist> insert(BanIllustIdPersist todo) async {
    todo.id = await db.insert(tableBanIllustId, todo.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return todo;
  }

  Future<BanIllustIdPersist> getAccount(int id) async {
    List<Map> maps = await db.query(tableBanIllustId,
        columns: [columnId, columnIllustId],
        where: '$columnId = ?',
        whereArgs: [id]);
    if (maps.length > 0) {
      return BanIllustIdPersist.fromJson(maps.first);
    }
    return null;
  }

  Future<List<BanIllustIdPersist>> getAllAccount() async {
    List result = new List<BanIllustIdPersist>();
    List<Map> maps = await db.query(tableBanIllustId,
        columns: [columnId, columnIllustId, columnName]);

    if (maps.length > 0) {
      maps.forEach((f) {
        result.add(BanIllustIdPersist.fromJson(f));
      });
    }
    return result;
  }

  Future<int> delete(int id) async {
    return await db
        .delete(tableBanIllustId, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> deleteAll() async {
    return await db.delete(tableBanIllustId);
  }

  Future<int> update(BanIllustIdPersist todo) async {
    return await db.update(tableBanIllustId, todo.toJson(),
        where: '$columnId = ?', whereArgs: [todo.id]);
  }

  Future close() async => db.close();
}
