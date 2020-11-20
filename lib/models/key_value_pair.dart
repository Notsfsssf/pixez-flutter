import 'package:sqflite/sqflite.dart';
import 'dart:convert' show json;
import 'package:path/path.dart';

final String tableKVPair = 'kvpair';
final String columnId = '_id';
final String columnKey = 'key';
final String columnValue = 'value';
final String columnExpireTime = 'expire_time';
final String columnDateTime = 'date_time';

class KVPair {
  String key;
  String value;
  int expireTime;
  int dateTime;
  KVPair({this.key, this.value, this.expireTime, this.dateTime});

  factory KVPair.fromJson(jsonRes) => jsonRes == null
      ? null
      : KVPair(
          key: jsonRes['key'],
          value: jsonRes['value'],
          expireTime: jsonRes['expire_time'],
          dateTime: jsonRes['date_time']);

  Map<String, dynamic> toJson() => {
        'key': key,
        'value': value,
        'expire_time': expireTime,
        'date_time': dateTime
      };

  @override
  String toString() {
    return json.encode(this);
  }
}

class KVProvider {
  Database db;

  Future open() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'kvpair.db');
    db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute('''
create table $tableKVPair ( 
  $columnId integer primary key autoincrement, 
  $columnKey text not null,
  $columnValue text not null,
  $columnExpireTime integer not null,
  $columnDateTime integer not null,
  )
''');
    });
  }

  Future<void> insert(KVPair todo) async {
    await db.insert(tableKVPair, todo.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return todo;
  }

  Future<KVPair> getAccount(String key) async {
    List<Map> maps = await db.query(tableKVPair,
        columns: [
          columnId,
          columnKey,
          columnValue,
          columnExpireTime,
          columnDateTime,
        ],
        where: '$columnKey = ?',
        whereArgs: [key]);
    if (maps.length > 0) {
      return KVPair.fromJson(maps.first);
    }
    return null;
  }

  Future<int> remove(String key) async {
    final result =
        await db.delete(tableKVPair, where: '$columnKey = ?', whereArgs: [key]);
    return result;
  }

  Future<int> deleteAll() async {
    final result = await db.delete(tableKVPair);
    return result;
  }

  Future<int> update(todo) async {
    return await db.update(tableKVPair, todo.toJson(),
        where: '$columnId = ?', whereArgs: [todo.id]);
  }

  Future<List<KVPair>> getAllAccount() async {
    List result = new List<KVPair>();
    List<Map> maps = await db.query(tableKVPair, columns: [
      columnId,
      columnKey,
      columnValue,
      columnExpireTime,
      columnDateTime,
    ]);

    if (maps.length > 0) {
      maps.forEach((f) {
        result.add(KVPair.fromJson(f));
      });
    }
    return result;
  }
}
