/*
 * Copyright (C) 2020. by perol_notsf, All rights reserved
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program. If not, see <http://www.gnu.org/licenses/>.
 *
 */
import 'package:json_annotation/json_annotation.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

part 'account.g.dart';

@JsonSerializable()
class Account {
  final AccountResponse response;

  Account({required this.response});

  factory Account.fromJson(Map<String, dynamic> json) =>
      _$AccountFromJson(json);

  Map<String, dynamic> toJson() => _$AccountToJson(this);
}

final String tableAccount = 'account';
final String columnId = 'id';
final String columnUserId = 'user_id';
final String columnUserImage = 'user_image';
final String columnPassWord = 'password';
final String columnAccessToken = 'access_token';
final String columnDeviceToken = 'device_token';
final String columnRefreshToken = 'refresh_token';
final String columnName = 'name';
final String columnAccount = 'account';
final String columnMailAddress = 'mail_address';
final String columnIsPremium = 'is_premium';
final String columnXRestrict = 'x_restrict';
final String columnIsMailAuthorized = 'is_mail_authorized';

class AccountProvider {
  late Database db;

  Future open() async {
    String databasesPath = (await getDatabasesPath());
    String path = join(databasesPath, 'account.db');
    db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute('''
create table $tableAccount ( 
  $columnId integer primary key autoincrement, 
  $columnAccessToken text not null,
  $columnRefreshToken text not null,
  $columnDeviceToken text not null,
  $columnUserId text not null,
  $columnUserImage text not null,
  $columnName text not null,
  $columnPassWord text not null,
  $columnAccount text not null,
  $columnMailAddress text not null,
  $columnIsPremium integer not null,
  $columnXRestrict integer not null,
  $columnIsMailAuthorized integer not null
  )
''');
    });
  }

  Future<AccountPersist> insert(AccountPersist todo) async {
    todo.id = await db.insert(tableAccount, todo.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return todo;
  }

  Future<AccountPersist?> getAccount(int id) async {
    List<Map<String, dynamic>> maps = await db.query(tableAccount,
        columns: [
          columnId,
          columnUserImage,
          columnAccessToken,
          columnRefreshToken,
          columnDeviceToken,
          columnUserId,
          columnName,
          columnPassWord,
          columnAccount,
          columnMailAddress,
          columnMailAddress,
          columnIsPremium,
          columnXRestrict,
          columnIsMailAuthorized
        ],
        where: '$columnId = ?',
        whereArgs: [id]);
    if (maps.length > 0) {
      return AccountPersist.fromJson(maps.first);
    }
    return null;
  }

  Future<List<AccountPersist>> getAllAccount() async {
    List<AccountPersist> result = [];
    List<Map<String, dynamic>> maps = await db.query(tableAccount, columns: [
      columnId,
      columnUserImage,
      columnAccessToken,
      columnRefreshToken,
      columnDeviceToken,
      columnUserId,
      columnName,
      columnAccount,
      columnMailAddress,
      columnMailAddress,
      columnPassWord,
      columnIsPremium,
      columnXRestrict,
      columnIsMailAuthorized
    ]);

    if (maps.length > 0) {
      maps.forEach((f) {
        result.add(AccountPersist.fromJson(f));
      });
    }
    return result;
  }

  Future<int> delete(int id) async {
    return await db
        .delete(tableAccount, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> deleteByUserId(String userId) async {
    return await db
        .delete(tableAccount, where: '$columnUserId = ?', whereArgs: [userId]);
  }

  Future<int> deleteAll() async {
    return await db.delete(tableAccount);
  }

  Future<int> update(AccountPersist todo) async {
    return await db.update(tableAccount, todo.toJson(),
        where: '$columnId = ?', whereArgs: [todo.id]);
  }

  Future close() async => db.close();
}

@JsonSerializable()
class AccountPersist {
  int? id;
  @JsonKey(name: 'user_id')
  String userId;
  @JsonKey(name: 'user_image')
  String userImage;
  @JsonKey(name: 'access_token')
  String accessToken;
  @JsonKey(name: 'refresh_token')
  String refreshToken;
  @JsonKey(name: 'device_token')
  String deviceToken;
  String name;
  String account;
  @JsonKey(name: 'mail_address')
  String mailAddress;
  @JsonKey(name: 'password')
  String passWord;
  @JsonKey(name: 'is_premium')
  int isPremium;
  @JsonKey(name: 'x_restrict')
  int xRestrict;
  @JsonKey(name: 'is_mail_authorized')
  int isMailAuthorized;

  AccountPersist(
      {required this.userId,
      this.id,
      required this.userImage,
      required this.accessToken,
      required this.refreshToken,
      required this.deviceToken,
      required this.passWord,
      required this.name,
      required this.account,
      required this.mailAddress,
      required this.isPremium,
      required this.xRestrict,
      required this.isMailAuthorized});

  factory AccountPersist.fromJson(Map<String, dynamic> json) =>
      _$AccountPersistFromJson(json);

  Map<String, dynamic> toJson() => _$AccountPersistToJson(this);
}

extension AccountPersistEx on AccountPersist {
  String hiddenEmail() {
    final splits = mailAddress.split('@');
    var preText = '';
    for (var i = 0; i < splits[0].length; i++) {
      preText += '*';
    }
    return '${preText}@${splits[1]}';
  }
}

@JsonSerializable()
class AccountResponse {
  @JsonKey(name: "access_token")
  String accessToken;
  @JsonKey(name: "expires_in")
  int expiresIn;
  @JsonKey(name: "token_type")
  String tokenType;
  String scope;
  @JsonKey(name: 'refresh_token')
  String refreshToken;
  User user;

  factory AccountResponse.fromJson(Map<String, dynamic> json) =>
      _$AccountResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AccountResponseToJson(this);

  AccountResponse(
      {required this.accessToken,
      required this.expiresIn,
      required this.tokenType,
      required this.scope,
      required this.refreshToken,
      required this.user});
}

@JsonSerializable()
class User {
  @JsonKey(name: 'profile_image_urls')
  ProfileImageUrls profileImageUrls;
  String id;
  String name;
  String account;
  @JsonKey(name: 'mail_address')
  String mailAddress;
  @JsonKey(name: 'is_premium')
  bool isPremium;
  @JsonKey(name: 'x_restrict')
  int xRestrict;
  @JsonKey(name: 'is_mail_authorized')
  bool isMailAuthorized;
  @JsonKey(name: 'require_policy_agreement')
  bool? requirePolicyAgreement;

  User(
      {required this.profileImageUrls,
      required this.id,
      required this.name,
      required this.account,
      required this.mailAddress,
      required this.isPremium,
      required this.xRestrict,
      required this.isMailAuthorized});

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}

@JsonSerializable()
class ProfileImageUrls {
  @JsonKey(name: "px_16x16")
  String px16x16;
  @JsonKey(name: "px_50x50")
  String px50x50;
  @JsonKey(name: "px_170x170")
  String px170x170;

  ProfileImageUrls(
      {required this.px16x16, required this.px50x50, required this.px170x170});

  factory ProfileImageUrls.fromJson(Map<String, dynamic> json) =>
      _$ProfileImageUrlsFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileImageUrlsToJson(this);
}
