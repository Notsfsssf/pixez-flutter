import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class BanTagPersist {
  int id;
  String name;
  String translateName;

  BanTagPersist();

  BanTagPersist.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json[columnName];
    translateName = json[columnTranslateName];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data[columnTranslateName] = this.translateName;
    data[columnName] = this.name;
    return data;
  }
}

final String columnId = 'id';
final String columnTranslateName = 'translate_name';
final String columnName = 'name';
final String tableBanTag = 'bantag';

class BanTagProvider {
  Database db;

  Future open() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'bantag.db');
    db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute('''
create table $tableBanTag ( 
  $columnId integer primary key autoincrement, 
  $columnTranslateName text not null,
  $columnName text not null
  )
''');
    });
  }

  Future<BanTagPersist> insert(BanTagPersist todo) async {
    todo.id = await db.insert(tableBanTag, todo.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return todo;
  }

  Future<BanTagPersist> getAccount(int id) async {
    List<Map> maps = await db.query(tableBanTag,
        columns: [columnId, columnTranslateName],
        where: '$columnId = ?',
        whereArgs: [id]);
    if (maps.length > 0) {
      return BanTagPersist.fromJson(maps.first);
    }
    return null;
  }

  Future<List<BanTagPersist>> getAllAccount() async {
    List result = new List<BanTagPersist>();
    List<Map> maps = await db.query(tableBanTag,
        columns: [columnId, columnTranslateName, columnName]);

    if (maps.length > 0) {
      maps.forEach((f) {
        result.add(BanTagPersist.fromJson(f));
      });
    }
    return result;
  }

  Future<int> delete(int id) async {
    return await db
        .delete(tableBanTag, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> deleteAll() async {
    return await db.delete(tableBanTag);
  }

  Future<int> update(BanTagPersist todo) async {
    return await db.update(tableBanTag, todo.toJson(),
        where: '$columnId = ?', whereArgs: [todo.id]);
  }

  Future close() async => db.close();
}
