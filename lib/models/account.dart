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

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Account {
  AccountResponse response;

  Account({this.response});

  Account.fromJson(Map<String, dynamic> json) {
    this
      ..id = json['id'] as int
      ..userName = json['userName'] as String
      ..title = json['title'] as String
      ..url = json['url'] as String
      ..userId = json['userId'] as int
      ..illustId = json['illustId'] as int;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.response != null) {
      data['response'] = this.response.toJson();
    }
    return data;
  }
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
  Database db;

  Future open() async {
    String databasesPath = await getDatabasesPath();
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

  Future<AccountPersist> getAccount(int id) async {
    List<Map> maps = await db.query(tableAccount,
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
    List result = new List<AccountPersist>();
    List<Map> maps = await db.query(tableAccount, columns: [
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

  Future<int> deleteAll() async {
    return await db.delete(tableAccount);
  }

  Future<int> update(AccountPersist todo) async {
    return await db.update(tableAccount, todo.toJson(),
        where: '$columnId = ?', whereArgs: [todo.id]);
  }

  Future close() async => db.close();
}

class AccountPersist {
  int id;
  String userId;
  String userImage;
  String accessToken;
  String refreshToken;
  String deviceToken;
  String name;
  String account;
  String mailAddress;
  String passWord;
  int isPremium;
  int xRestrict;
  int isMailAuthorized;

  AccountPersist(
      {this.userId,
      this.userImage,
      this.accessToken,
      this.refreshToken,
      this.deviceToken,
      this.name,
      this.account,
      this.mailAddress,
      this.isPremium,
      this.xRestrict,
      this.isMailAuthorized});

  AccountPersist.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    accessToken = json['access_token'];
    refreshToken = json['refresh_token'];
    deviceToken = json['device_token'];
    userImage = json[columnUserImage];
    name = json['name'];
    account = json['account'];
    mailAddress = json['mail_address'];
    isPremium = json['is_premium'];
    xRestrict = json['x_restrict'];
    passWord = json[columnPassWord];
    isMailAuthorized = json['is_mail_authorized'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data[columnAccessToken] = this.accessToken;
    data[columnRefreshToken] = this.refreshToken;
    data[columnDeviceToken] = this.deviceToken;
    data['name'] = this.name;
    data[columnPassWord] = this.passWord;
    data['account'] = this.account;
    data['mail_address'] = this.mailAddress;
    data['is_premium'] = this.isPremium;
    data['x_restrict'] = this.xRestrict;
    data['is_mail_authorized'] = this.isMailAuthorized;
    data[columnUserImage] = this.userImage;
    return data;
  }
}

class AccountResponse {
  String accessToken;
  int expiresIn;
  String tokenType;
  String scope;
  String refreshToken;
  User user;
  String deviceToken;

  AccountResponse(
      {this.accessToken,
      this.expiresIn,
      this.tokenType,
      this.scope,
      this.refreshToken,
      this.user,
      this.deviceToken});

  AccountResponse.fromJson(Map<String, dynamic> json) {
    accessToken = json['access_token'];
    expiresIn = json['expires_in'];
    tokenType = json['token_type'];
    scope = json['scope'];
    refreshToken = json['refresh_token'];
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
    deviceToken = json['device_token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['access_token'] = this.accessToken;
    data['expires_in'] = this.expiresIn;
    data['token_type'] = this.tokenType;
    data['scope'] = this.scope;
    data['refresh_token'] = this.refreshToken;
    if (this.user != null) {
      data['user'] = this.user.toJson();
    }
    data['device_token'] = this.deviceToken;
    return data;
  }
}

class User {
  ProfileImageUrls profileImageUrls;
  String id;
  String name;
  String account;
  String mailAddress;
  bool isPremium;
  int xRestrict;
  bool isMailAuthorized;

  User(
      {this.profileImageUrls,
      this.id,
      this.name,
      this.account,
      this.mailAddress,
      this.isPremium,
      this.xRestrict,
      this.isMailAuthorized});

  User.fromJson(Map<String, dynamic> json) {
    profileImageUrls = json['profile_image_urls'] != null
        ? new ProfileImageUrls.fromJson(json['profile_image_urls'])
        : null;
    id = json['id'];
    name = json['name'];
    account = json['account'];
    mailAddress = json['mail_address'];
    isPremium = json['is_premium'];
    xRestrict = json['x_restrict'];
    isMailAuthorized = json['is_mail_authorized'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.profileImageUrls != null) {
      data['profile_image_urls'] = this.profileImageUrls.toJson();
    }
    data['id'] = this.id;
    data['name'] = this.name;
    data['account'] = this.account;
    data['mail_address'] = this.mailAddress;
    data['is_premium'] = this.isPremium;
    data['x_restrict'] = this.xRestrict;
    data['is_mail_authorized'] = this.isMailAuthorized;
    return data;
  }
}

class ProfileImageUrls {
  String px16x16;
  String px50x50;
  String px170x170;

  ProfileImageUrls({this.px16x16, this.px50x50, this.px170x170});

  ProfileImageUrls.fromJson(Map<String, dynamic> json) {
    px16x16 = json['px_16x16'];
    px50x50 = json['px_50x50'];
    px170x170 = json['px_170x170'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['px_16x16'] = this.px16x16;
    data['px_50x50'] = this.px50x50;
    data['px_170x170'] = this.px170x170;
    return data;
  }
}
