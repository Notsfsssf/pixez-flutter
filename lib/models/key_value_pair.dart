import 'package:json_annotation/json_annotation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:convert' show json;
import 'package:path/path.dart';

part 'key_value_pair.g.dart';

final String tableKVPair = 'kvpair';
final String columnId = '_id';
final String columnKey = 'key';
final String columnValue = 'value';
final String columnExpireTime = 'expire_time';
final String columnDateTime = 'date_time';

@JsonSerializable()
class KVPair {
  String key;
  String value;
  @JsonKey(name: 'expire_time')
  int expireTime;
  @JsonKey(name: 'date_time')
  int dateTime;

  KVPair(
      {required this.key,
      required this.value,
      required this.expireTime,
      required this.dateTime});

  factory KVPair.fromJson(Map<String, dynamic> json) => _$KVPairFromJson(json);

  Map<String, dynamic> toJson() => _$KVPairToJson(this);

  @override
  String toString() {
    return json.encode(this);
  }
}

class KVProvider {
  late Database db;

  Future open() async {
    String databasesPath = (await getDatabasesPath());
    String path = join(databasesPath, 'kvpair.db');
    db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute('''
create table $tableKVPair ( 
  $columnId integer primary key autoincrement, 
  $columnKey text not null,
  $columnValue text not null,
  $columnExpireTime integer not null,
  $columnDateTime integer not null
  )
''');
    });
  }

  Future<void> insert(KVPair todo) async {
    await db.insert(tableKVPair, todo.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<KVPair?> getAccount(String key) async {
    List<Map<String, dynamic>> maps = await db.query(tableKVPair,
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
    List<KVPair> result = [];
    List<Map<String, dynamic>> maps = await db.query(tableKVPair, columns: [
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

  Future<void> delete(String key) async {
    await db.delete(tableKVPair, where: '$columnKey = ?', whereArgs: [key]);
  }
}
