import 'dart:convert' show json;


class UserDetail {
  User user;
  Profile profile;
  Profile_publicity profile_publicity;
  Workspace workspace;

  UserDetail({
    this.user,
    this.profile,
    this.profile_publicity,
    this.workspace,
  });

  factory UserDetail.fromJson(jsonRes) =>
      jsonRes == null
          ? null
          : UserDetail(
        user: User.fromJson(jsonRes['user']),
        profile: Profile.fromJson(jsonRes['profile']),
        profile_publicity:
        Profile_publicity.fromJson(jsonRes['profile_publicity']),
        workspace: Workspace.fromJson(jsonRes['workspace']),
      );

  Map<String, dynamic> toJson() =>
      {
        'user': user,
        'profile': profile,
        'profile_publicity': profile_publicity,
        'workspace': workspace,
      };

  @override
  String toString() {
    return json.encode(this);
  }
}

class User {
  int id;
  String name;
  String account;
  Profile_image_urls profile_image_urls;
  String comment;
  bool is_followed;

  User({
    this.id,
    this.name,
    this.account,
    this.profile_image_urls,
    this.comment,
    this.is_followed,
  });

  factory User.fromJson(jsonRes) =>
      jsonRes == null
          ? null
          : User(
        id: jsonRes['id'],
        name: jsonRes['name'],
        account: jsonRes['account'],
        profile_image_urls:
        Profile_image_urls.fromJson(jsonRes['profile_image_urls']),
        comment: jsonRes['comment'],
        is_followed: jsonRes['is_followed'],
      );

  Map<String, dynamic> toJson() =>
      {
        'id': id,
        'name': name,
        'account': account,
        'profile_image_urls': profile_image_urls,
        'comment': comment,
        'is_followed': is_followed,
      };

  @override
  String toString() {
    return json.encode(this);
  }
}

class Profile_image_urls {
  String medium;

  Profile_image_urls({
    this.medium,
  });

  factory Profile_image_urls.fromJson(jsonRes) =>
      jsonRes == null
          ? null
          : Profile_image_urls(
        medium: jsonRes['medium'],
      );

  Map<String, dynamic> toJson() =>
      {
        'medium': medium,
      };

  @override
  String toString() {
    return json.encode(this);
  }
}

class Profile {
  String webpage;
  String gender;
  String birth;
  String birth_day;
  int birth_year;
  String region;
  int address_id;
  String country_code;
  String job;
  int job_id;
  int total_follow_users;
  int total_mypixiv_users;
  int total_illusts;
  int total_manga;
  int total_novels;
  int total_illust_bookmarks_public;
  int total_illust_series;
  int total_novel_series;
  Object background_image_url;
  String twitter_account;
  Object twitter_url;
  String pawoo_url;
  bool is_premium;
  bool is_using_custom_profile_image;

  Profile({
    this.webpage,
    this.gender,
    this.birth,
    this.birth_day,
    this.birth_year,
    this.region,
    this.address_id,
    this.country_code,
    this.job,
    this.job_id,
    this.total_follow_users,
    this.total_mypixiv_users,
    this.total_illusts,
    this.total_manga,
    this.total_novels,
    this.total_illust_bookmarks_public,
    this.total_illust_series,
    this.total_novel_series,
    this.background_image_url,
    this.twitter_account,
    this.twitter_url,
    this.pawoo_url,
    this.is_premium,
    this.is_using_custom_profile_image,
  });

  factory Profile.fromJson(jsonRes) =>
      jsonRes == null
          ? null
          : Profile(
        webpage: jsonRes['webpage'],
        gender: jsonRes['gender'],
        birth: jsonRes['birth'],
        birth_day: jsonRes['birth_day'],
        birth_year: jsonRes['birth_year'],
        region: jsonRes['region'],
        address_id: jsonRes['address_id'],
        country_code: jsonRes['country_code'],
        job: jsonRes['job'],
        job_id: jsonRes['job_id'],
        total_follow_users: jsonRes['total_follow_users'],
        total_mypixiv_users: jsonRes['total_mypixiv_users'],
        total_illusts: jsonRes['total_illusts'],
        total_manga: jsonRes['total_manga'],
        total_novels: jsonRes['total_novels'],
        total_illust_bookmarks_public:
        jsonRes['total_illust_bookmarks_public'],
        total_illust_series: jsonRes['total_illust_series'],
        total_novel_series: jsonRes['total_novel_series'],
        background_image_url: jsonRes['background_image_url'],
        twitter_account: jsonRes['twitter_account'],
        twitter_url: jsonRes['twitter_url'],
        pawoo_url: jsonRes['pawoo_url'],
        is_premium: jsonRes['is_premium'],
        is_using_custom_profile_image:
        jsonRes['is_using_custom_profile_image'],
      );

  Map<String, dynamic> toJson() =>
      {
        'webpage': webpage,
        'gender': gender,
        'birth': birth,
        'birth_day': birth_day,
        'birth_year': birth_year,
        'region': region,
        'address_id': address_id,
        'country_code': country_code,
        'job': job,
        'job_id': job_id,
        'total_follow_users': total_follow_users,
        'total_mypixiv_users': total_mypixiv_users,
        'total_illusts': total_illusts,
        'total_manga': total_manga,
        'total_novels': total_novels,
        'total_illust_bookmarks_public': total_illust_bookmarks_public,
        'total_illust_series': total_illust_series,
        'total_novel_series': total_novel_series,
        'background_image_url': background_image_url,
        'twitter_account': twitter_account,
        'twitter_url': twitter_url,
        'pawoo_url': pawoo_url,
        'is_premium': is_premium,
        'is_using_custom_profile_image': is_using_custom_profile_image,
      };

  @override
  String toString() {
    return json.encode(this);
  }
}

class Profile_publicity {
  String gender;
  String region;
  String birth_day;
  String birth_year;
  String job;
  bool pawoo;

  Profile_publicity({
    this.gender,
    this.region,
    this.birth_day,
    this.birth_year,
    this.job,
    this.pawoo,
  });

  factory Profile_publicity.fromJson(jsonRes) =>
      jsonRes == null
          ? null
          : Profile_publicity(
        gender: jsonRes['gender'],
        region: jsonRes['region'],
        birth_day: jsonRes['birth_day'],
        birth_year: jsonRes['birth_year'],
        job: jsonRes['job'],
        pawoo: jsonRes['pawoo'],
      );

  Map<String, dynamic> toJson() =>
      {
        'gender': gender,
        'region': region,
        'birth_day': birth_day,
        'birth_year': birth_year,
        'job': job,
        'pawoo': pawoo,
      };

  @override
  String toString() {
    return json.encode(this);
  }
}

class Workspace {
  String pc;
  String monitor;
  String tool;
  String scanner;
  String tablet;
  String mouse;
  String printer;
  String desktop;
  String music;
  String desk;
  String chair;
  String comment;
  Object workspace_image_url;

  Workspace({
    this.pc,
    this.monitor,
    this.tool,
    this.scanner,
    this.tablet,
    this.mouse,
    this.printer,
    this.desktop,
    this.music,
    this.desk,
    this.chair,
    this.comment,
    this.workspace_image_url,
  });

  factory Workspace.fromJson(jsonRes) =>
      jsonRes == null
          ? null
          : Workspace(
        pc: jsonRes['pc'],
        monitor: jsonRes['monitor'],
        tool: jsonRes['tool'],
        scanner: jsonRes['scanner'],
        tablet: jsonRes['tablet'],
        mouse: jsonRes['mouse'],
        printer: jsonRes['printer'],
        desktop: jsonRes['desktop'],
        music: jsonRes['music'],
        desk: jsonRes['desk'],
        chair: jsonRes['chair'],
        comment: jsonRes['comment'],
        workspace_image_url: jsonRes['workspace_image_url'],
      );

  Map<String, dynamic> toJson() =>
      {
        'pc': pc,
        'monitor': monitor,
        'tool': tool,
        'scanner': scanner,
        'tablet': tablet,
        'mouse': mouse,
        'printer': printer,
        'desktop': desktop,
        'music': music,
        'desk': desk,
        'chair': chair,
        'comment': comment,
        'workspace_image_url': workspace_image_url,
      };

  @override
  String toString() {
    return json.encode(this);
  }
}
