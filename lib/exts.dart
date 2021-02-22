/*
 * Copyright (C) 2020. by perol_notsf, All rights reserved
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful, but WITHOUT ANY
 *  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 *  FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License along with
 *  this program. If not, see <http://www.gnu.org/licenses/>.
 */
import 'package:intl/intl.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/illust.dart';
import 'package:pixez/constants.dart';



import 'constants.dart';
import 'main.dart';extension TimeExts on String {
  String toShortTime() {
    try {
      var formatter = new DateFormat('yyyy-MM-dd HH:mm:ss');
      return formatter.format(DateTime.parse(this));
    } catch (e) {
      return this ?? '';
    }
  }

  String toTranslateText() {
    return this
        .replaceAll("</br>", "\n")
        .replaceAll("<br />", "\n")
        .replaceAll("<strong>", "")
        .replaceAll("</strong>", "")
        .replaceAll("<p>", "")
        .replaceAll("</p>", "");
  }

  String toTrueUrl() {
    if (userSetting.disableBypassSni || this.contains("novel")) {
      return this;
    } else { //额,不太清楚在这几个是干啥的,反正都改一下,非图片是匹配不到的...
      if (this.contains(ImageHost)) {
        if (userSetting.pictureReverseProxy) {
          return this.replaceFirst(ImageHost, splashStore.host).replaceAll("i.pximg.net",Constants.reverseServer);
        } else{
          return this.replaceFirst(ImageHost, splashStore.host);
        }
      }
      if (this.contains(ImageSHost)) {
        if (userSetting.pictureReverseProxy) {
          return this.replaceFirst(ImageSHost, splashStore.host).replaceAll("i.pximg.net",Constants.reverseServer);
        } else {        
          return this.replaceFirst(ImageSHost, splashStore.host);
        }      
      }
    }
    if (userSetting.pictureReverseProxy) {
      return this.replaceAll("i.pximg.net",Constants.reverseServer);
    } else {
      return this;
    }
  }

  String toLegal() {
    return this
        .replaceAll("/", "")
        .replaceAll("\\", "")
        .replaceAll(":", "")
        .replaceAll("*", "")
        .replaceAll("?", "")
        .replaceAll(">", "")
        .replaceAll("|", "")
        .replaceAll("<", "");
  }
}

extension IllustExts on Illusts {
  bool hateByUser() {
    for (var t in muteStore.banTags) {
      for (var f in this.tags) {
        if (f.name == t.name) return true;
      }
    }
    for (var j in muteStore.banUserIds) {
      if (j.userId == this.user.id.toString()) {
        return true;
      }
    }

    for (var i in muteStore.banillusts)
      if (this.id == i.id) {
        return true;
      }
    return false;
  }
}
