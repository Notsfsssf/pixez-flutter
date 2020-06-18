import 'dart:io';

import 'package:dio/dio.dart';
import 'package:mobx/mobx.dart';
import 'package:pixez/models/user_detail.dart';
import 'package:pixez/network/api_client.dart';

part 'user_store.g.dart';

class UserStore = _UserStoreBase with _$UserStore;

abstract class _UserStoreBase with Store {
  final ApiClient client;
  final int id;
  @observable
  UserDetail userDetail;
  @observable
  bool isFollow = false;
  @observable
  int value = 0;

  _UserStoreBase(this.client, this.id);

  @action
  Future<void> follow({bool needPrivate = false}) async {
    if (userDetail.user.is_followed) {
      try {
        Response response = await client.postUnFollowUser(id);

        userDetail.user.is_followed = false;
        isFollow = userDetail.user.is_followed;
      } on DioError catch (e) {
        if (e.response != null &&
            e.response.statusCode == HttpStatus.badRequest) {}
      }
      return;
    }
    if (needPrivate) {
      try {
        Response response = await client.postFollowUser(id, 'private');
        userDetail.user.is_followed = true;
        isFollow = userDetail.user.is_followed;
      } on DioError catch (e) {
        if (e.response != null &&
            e.response.statusCode == HttpStatus.badRequest) {}
      }
    } else {
      try {
        Response response = await client.postFollowUser(id, 'public');
        userDetail.user.is_followed = true;
        isFollow = userDetail.user.is_followed;
      } on DioError catch (e) {
        if (e.response != null &&
            e.response.statusCode == HttpStatus.badRequest) {}
      }
    }
  }

  @observable
  String errorMessage;

  @action
  Future<void> firstFetch() async {
    try {
      Response response = await client.getUser(id);
      UserDetail userDetail = UserDetail.fromJson(response.data);
      this.userDetail = userDetail;
      this.isFollow = this.userDetail.user.is_followed;
    } on DioError catch (e) {
      if (e.response != null && e.response.statusCode == HttpStatus.notFound) {
        errorMessage = '404';
      } else {
        errorMessage = e.toString();
      }
    }
  }
}
