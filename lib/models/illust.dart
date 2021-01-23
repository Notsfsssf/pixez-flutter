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
 *F
 * You should have received a copy of the GNU General Public License along with
 * this program. If not, see <http://www.gnu.org/licenses/>.
 *
 */

class MetaPages {
  MetaPagesImageUrls imageUrls;

  MetaPages({this.imageUrls});

  MetaPages.fromJson(Map<String, dynamic> json) {
    imageUrls = json['image_urls'] != null
        ? new MetaPagesImageUrls.fromJson(json['image_urls'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.imageUrls != null) {
      data['image_urls'] = this.imageUrls.toJson();
    }
    return data;
  }
}

class MetaPagesImageUrls {
  String squareMedium;
  String medium;
  String large;
  String original;

  MetaPagesImageUrls(
      {this.squareMedium, this.medium, this.large, this.original});

  MetaPagesImageUrls.fromJson(Map<String, dynamic> json) {
    squareMedium = json['square_medium'];
    medium = json['medium'];
    large = json['large'];
    original = json['original'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['square_medium'] = this.squareMedium;
    data['medium'] = this.medium;
    data['large'] = this.large;
    data['original'] = this.original;
    return data;
  }
}

class Illusts {
  int id;
  String title;
  String type;
  ImageUrls imageUrls;
  String caption;
  int restrict;
  User user;
  List<Tags> tags;
  List<String> tools;
  String createDate;
  int pageCount;
  int width;
  int height;
  int sanityLevel;
  int xRestrict;
  Object series;
  MetaSinglePage metaSinglePage;
  List<MetaPages> metaPages;
  int totalView;
  int totalBookmarks;
  bool isBookmarked;
  bool visible;
  bool isMuted;

  Illusts(
      {this.id,
      this.title,
      this.type,
      this.imageUrls,
      this.caption,
      this.restrict,
      this.user,
      this.tags,
      this.tools,
      this.createDate,
      this.pageCount,
      this.width,
      this.height,
      this.sanityLevel,
      this.xRestrict,
      this.series,
      this.metaSinglePage,
      this.metaPages,
      this.totalView,
      this.totalBookmarks,
      this.isBookmarked,
      this.visible,
      this.isMuted});
  Illusts.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    type = json['type'];
    imageUrls = json['image_urls'] != null
        ? new ImageUrls.fromJson(json['image_urls'])
        : null;
    caption = json['caption'];
    restrict = json['restrict'];
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
    if (json['tags'] != null) {
      tags = new List<Tags>();
      json['tags'].forEach((v) {
        tags.add(new Tags.fromJson(v));
      });
    }
    if (json['tools'] != null) {
      tools = new List<String>();
      json['tools'].forEach((v) {
        tools.add(v);
      });
    }
    createDate = json['create_date'];
    pageCount = json['page_count'];
    width = json['width'];
    height = json['height'];
    sanityLevel = json['sanity_level'];
    xRestrict = json['x_restrict'];
    series = json['series'];
    metaSinglePage = json['meta_single_page'] != null
        ? new MetaSinglePage.fromJson(json['meta_single_page'])
        : null;
    if (json['meta_pages'] != null) {
      metaPages = new List<MetaPages>();
      json['meta_pages'].forEach((v) {
        metaPages.add(new MetaPages.fromJson(v));
      });
    }
    totalView = json['total_view'];
    totalBookmarks = json['total_bookmarks'];
    isBookmarked = json['is_bookmarked'];
    visible = json['visible'];
    isMuted = json['is_muted'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['type'] = this.type;
    if (this.imageUrls != null) {
      data['image_urls'] = this.imageUrls.toJson();
    }
    data['caption'] = this.caption;
    data['restrict'] = this.restrict;
    if (this.user != null) {
      data['user'] = this.user.toJson();
    }
    if (this.tags != null) {
      data['tags'] = this.tags.map((v) => v.toJson()).toList();
    }
    if (this.tools != null) {
      data['tools'] = this.tools.map((v) => v).toList();
    }
    data['create_date'] = this.createDate;
    data['page_count'] = this.pageCount;
    data['width'] = this.width;
    data['height'] = this.height;
    data['sanity_level'] = this.sanityLevel;
    data['x_restrict'] = this.xRestrict;
    data['series'] = this.series;
    if (this.metaSinglePage != null) {
      data['meta_single_page'] = this.metaSinglePage.toJson();
    }
    if (this.metaPages != null) {
      data['meta_pages'] = this.metaPages.map((v) => v.toJson()).toList();
    }
    data['total_view'] = this.totalView;
    data['total_bookmarks'] = this.totalBookmarks;
    data['is_bookmarked'] = this.isBookmarked;
    data['visible'] = this.visible;
    data['is_muted'] = this.isMuted;
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
  String comment;
  bool isFollowed;

  User(
      {this.id,
      this.name,
      this.account,
      this.profileImageUrls,
      this.comment,
      this.isFollowed});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    account = json['account'];
    profileImageUrls = json['profile_image_urls'] != null
        ? new ProfileImageUrls.fromJson(json['profile_image_urls'])
        : null;
    comment = json['comment'];
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
    data['comment']= this.comment;
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
  String translatedName;

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
