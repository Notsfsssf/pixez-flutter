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
  String? tagName;
  List<Assets>? assets;
  String? body;

  LastRelease({this.tagName, this.assets, this.body});

  factory LastRelease.fromJson(Map<String, dynamic> json) {
    List<Assets>? assets;
    if (json['assets'] != null) {
      assets = [];
      json['assets'].forEach((v) {
        assets!.add(Assets.fromJson(v));
      });
    }
    return LastRelease(
      tagName: json['tag_name']?.toString(),
      assets: assets,
      body: json['body']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['tag_name'] = this.tagName;
    if (this.assets != null) {
      data['assets'] = this.assets!.map((v) => v.toJson()).toList();
    }
    data['body'] = this.body;
    return data;
  }
}

class Assets {
  String? browserDownloadUrl;

  Assets({this.browserDownloadUrl});

  factory Assets.fromJson(Map<String, dynamic> json) {
    return Assets(browserDownloadUrl: json['browser_download_url']?.toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['browser_download_url'] = this.browserDownloadUrl;
    return data;
  }
}
