
import 'package:pixez/models/illust.dart';

class Recommend {
  List<Illusts> illusts;
  List<Illusts> rankingIllusts;
  bool contestExists;
  PrivacyPolicy privacyPolicy;
  String nextUrl;

  Recommend({this.illusts, this.rankingIllusts, this.contestExists, this.privacyPolicy, this.nextUrl});

  Recommend.fromJson(Map<String, dynamic> json) {
    if (json['illusts'] != null) {
      illusts = new List<Illusts>();
      json['illusts'].forEach((v) { illusts.add(new Illusts.fromJson(v)); });
    }
    if (json['ranking_illusts'] != null) {
      rankingIllusts = new List<Illusts>();
      json['ranking_illusts'].forEach((v) { rankingIllusts.add(new Illusts.fromJson(v)); });
    }
    contestExists = json['contest_exists'];
    privacyPolicy = json['privacy_policy'] != null ? new PrivacyPolicy.fromJson(json['privacy_policy']) : null;
    nextUrl = json['next_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.illusts != null) {
      data['illusts'] = this.illusts.map((v) => v.toJson()).toList();
    }
    if (this.rankingIllusts != null) {
      data['ranking_illusts'] = this.rankingIllusts.map((v) => v.toJson()).toList();
    }
    data['contest_exists'] = this.contestExists;
    if (this.privacyPolicy != null) {
      data['privacy_policy'] = this.privacyPolicy.toJson();
    }
    data['next_url'] = this.nextUrl;
    return data;
  }
}



class ImageUrls {
  String squareMedium;
  String medium;
  String large;

  ImageUrls({this.squareMedium, this.medium, this.large});

  ImageUrls.fromJson(Map<String, dynamic> json) {
    squareMedium = json['square_medium'];
    medium = json['medium'];
    large = json['large'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['square_medium'] = this.squareMedium;
    data['medium'] = this.medium;
    data['large'] = this.large;
    return data;
  }
}

class User {
  int id;
  String name;
  String account;
  ProfileImageUrls profileImageUrls;
  bool isFollowed;

  User({this.id, this.name, this.account, this.profileImageUrls, this.isFollowed});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    account = json['account'];
    profileImageUrls = json['profile_image_urls'] != null ? new ProfileImageUrls.fromJson(json['profile_image_urls']) : null;
    isFollowed = json['is_followed'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['account'] = this.account;
    if (this.profileImageUrls != null) {
      data['profile_image_urls'] = this.profileImageUrls.toJson();
    }
    data['is_followed'] = this.isFollowed;
    return data;
  }
}

class ProfileImageUrls {
  String medium;

  ProfileImageUrls({this.medium});

  ProfileImageUrls.fromJson(Map<String, dynamic> json) {
    medium = json['medium'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['medium'] = this.medium;
    return data;
  }
}

class Tags {
  String name;
  Null translatedName;

  Tags({this.name, this.translatedName});

  Tags.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    translatedName = json['translated_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['translated_name'] = this.translatedName;
    return data;
  }
}

class MetaSinglePage {
  String originalImageUrl;

  MetaSinglePage({this.originalImageUrl});

  MetaSinglePage.fromJson(Map<String, dynamic> json) {
    originalImageUrl = json['original_image_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['original_image_url'] = this.originalImageUrl;
    return data;
  }
}

class PrivacyPolicy {


  PrivacyPolicy();

PrivacyPolicy.fromJson(Map<String, dynamic> json) {
}

Map<String, dynamic> toJson() {
  final Map<String, dynamic> data = new Map<String, dynamic>();
  return data;
}
}