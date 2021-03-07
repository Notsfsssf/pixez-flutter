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
class LastRelease {
  String url;
  String assetsUrl;
  String uploadUrl;
  String htmlUrl;
  int id;
  String nodeId;
  String tagName;
  String targetCommitish;
  String name;
  bool draft;
  Author author;
  bool prerelease;
  String createdAt;
  String publishedAt;
  List<Assets> assets;
  String tarballUrl;
  String zipballUrl;
  String body;

  LastRelease(
      {required this.url,
      required this.assetsUrl,
      required this.uploadUrl,
      required this.htmlUrl,
      required this.id,
      required this.nodeId,
      required this.tagName,
      required this.targetCommitish,
      required this.name,
      required this.draft,
      required this.author,
      required this.prerelease,
      required this.createdAt,
      required this.publishedAt,
      required this.assets,
      required this.tarballUrl,
      required this.zipballUrl,
      required this.body});

  factory LastRelease.fromJson(Map<String, dynamic> json) {
    List<Assets> assets = [];
    if (json['assets'] != null) {
      json['assets'].forEach((v) {
        assets.add(new Assets.fromJson(v));
      });
    }
    return LastRelease(
        url: json['url'],
        assetsUrl: json['assets_url'],
        uploadUrl: json['upload_url'],
        htmlUrl: json['html_url'],
        id: json['id'],
        nodeId: json['node_id'],
        tagName: json['tag_name'],
        targetCommitish: json['target_commitish'],
        name: json['name'],
        draft: json['draft'],
        author: Author.fromJson(json['author']),
        prerelease: json['prerelease'],
        createdAt: json['created_at'],
        publishedAt: json['published_at'],
        assets: assets,
        tarballUrl: json['tarball_url'],
        zipballUrl: json['zipball_url'],
        body: json['body']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['url'] = this.url;
    data['assets_url'] = this.assetsUrl;
    data['upload_url'] = this.uploadUrl;
    data['html_url'] = this.htmlUrl;
    data['id'] = this.id;
    data['node_id'] = this.nodeId;
    data['tag_name'] = this.tagName;
    data['target_commitish'] = this.targetCommitish;
    data['name'] = this.name;
    data['draft'] = this.draft;
    data['author'] = this.author.toJson();
    data['prerelease'] = this.prerelease;
    data['created_at'] = this.createdAt;
    data['published_at'] = this.publishedAt;
    data['assets'] = this.assets.map((v) => v.toJson()).toList();
    data['tarball_url'] = this.tarballUrl;
    data['zipball_url'] = this.zipballUrl;
    data['body'] = this.body;
    return data;
  }
}

class Author {
  String login;
  int id;
  String nodeId;
  String avatarUrl;
  String gravatarId;
  String url;
  String htmlUrl;
  String followersUrl;
  String followingUrl;
  String gistsUrl;
  String starredUrl;
  String subscriptionsUrl;
  String organizationsUrl;
  String reposUrl;
  String eventsUrl;
  String receivedEventsUrl;
  String type;
  bool siteAdmin;

  Author(
      {required this.login,
      required this.id,
      required this.nodeId,
      required this.avatarUrl,
      required this.gravatarId,
      required this.url,
      required this.htmlUrl,
      required this.followersUrl,
      required this.followingUrl,
      required this.gistsUrl,
      required this.starredUrl,
      required this.subscriptionsUrl,
      required this.organizationsUrl,
      required this.reposUrl,
      required this.eventsUrl,
      required this.receivedEventsUrl,
      required this.type,
      required this.siteAdmin});

  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
        login: json['login'],
        id: json['id'],
        nodeId: json['node_id'],
        avatarUrl: json['avatar_url'],
        gravatarId: json['gravatar_id'],
        url: json['url'],
        htmlUrl: json['html_url'],
        followersUrl: json['followers_url'],
        followingUrl: json['following_url'],
        gistsUrl: json['gists_url'],
        starredUrl: json['starred_url'],
        subscriptionsUrl: json['subscriptions_url'],
        organizationsUrl: json['organizations_url'],
        reposUrl: json['repos_url'],
        eventsUrl: json['events_url'],
        receivedEventsUrl: json['received_events_url'],
        type: json['type'],
        siteAdmin: json['site_admin']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['login'] = this.login;
    data['id'] = this.id;
    data['node_id'] = this.nodeId;
    data['avatar_url'] = this.avatarUrl;
    data['gravatar_id'] = this.gravatarId;
    data['url'] = this.url;
    data['html_url'] = this.htmlUrl;
    data['followers_url'] = this.followersUrl;
    data['following_url'] = this.followingUrl;
    data['gists_url'] = this.gistsUrl;
    data['starred_url'] = this.starredUrl;
    data['subscriptions_url'] = this.subscriptionsUrl;
    data['organizations_url'] = this.organizationsUrl;
    data['repos_url'] = this.reposUrl;
    data['events_url'] = this.eventsUrl;
    data['received_events_url'] = this.receivedEventsUrl;
    data['type'] = this.type;
    data['site_admin'] = this.siteAdmin;
    return data;
  }
}

class Assets {
  String url;
  int id;
  String nodeId;
  String name;
  Null label;
  Author uploader;
  String contentType;
  String state;
  int size;
  int downloadCount;
  String createdAt;
  String updatedAt;
  String browserDownloadUrl;

  Assets(
      {required this.url,
      required this.id,
      required this.nodeId,
      required this.name,
      required this.label,
      required this.uploader,
      required this.contentType,
      required this.state,
      required this.size,
      required this.downloadCount,
      required this.createdAt,
      required this.updatedAt,
      required this.browserDownloadUrl});

  factory Assets.fromJson(Map<String, dynamic> json) {
    return Assets(
      url: json['url'],
      id: json['id'],
      nodeId: json['node_id'],
      name: json['name'],
      label: json['label'],
      uploader: new Author.fromJson(json['uploader']),
      contentType: json['content_type'],
      state: json['state'],
      size: json['size'],
      downloadCount: json['download_count'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      browserDownloadUrl: json['browser_download_url'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['url'] = this.url;
    data['id'] = this.id;
    data['node_id'] = this.nodeId;
    data['name'] = this.name;
    data['label'] = this.label;
    data['uploader'] = this.uploader.toJson();
    data['content_type'] = this.contentType;
    data['state'] = this.state;
    data['size'] = this.size;
    data['download_count'] = this.downloadCount;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['browser_download_url'] = this.browserDownloadUrl;
    return data;
  }
}
