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

import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pixez/er/lprinter.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/account.dart';
import 'package:pixez/network/oauth_client.dart';
import 'package:pixez/page/hello/android_hello_page.dart';
import 'package:pixez/page/hello/hello_page.dart';
import 'package:pixez/page/novel/viewer/novel_viewer.dart';
import 'package:pixez/page/picture/illust_lighting_page.dart';
import 'package:pixez/page/search/result_page.dart';
import 'package:pixez/page/soup/soup_page.dart';
import 'package:pixez/page/user/users_page.dart';
import 'package:url_launcher/url_launcher.dart';

class Leader {
  static Future<void> pushUntilHome(BuildContext context) async {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
          builder: (context) =>
              Platform.isIOS ? HelloPage() : AndroidHelloPage()),
      (route) => route == null,
    );
  }

  static Future<void> pushWithUri(BuildContext context, Uri link) async {
    if (link.host == "pixiv.me") {
      try {
        BotToast.showText(text: "Pixiv me...");
        var dio = Dio();
        Response response = await dio.getUri(link);
        if (response.isRedirect == true) {
          Uri source = response.realUri;
          LPrinter.d("here we go pixiv me:" + source.toString());
          pushWithUri(context, source);
          return;
        }
      } catch (e) {
        try {
          launch(link.toString());
        } catch (e) {}
      }
      return;
    }
    if (link.host.contains("pixivision.net")) {
      Leader.push(
          context,
          SoupPage(
              url: link.toString().replaceAll("pixez://", "https://"),
              spotlight: null));
      return;
    }
    if (link.scheme == "pixiv") {
      if (link.host.contains("account")) {
        try {
          BotToast.showText(text: "working....");
          String code = link.queryParameters['code']!;
          LPrinter.d("here we go:" + code);
          Response response = await oAuthClient.code2Token(code);
          AccountResponse accountResponse =
              Account.fromJson(response.data).response;
          final user = accountResponse.user;
          AccountProvider accountProvider = new AccountProvider();
          await accountProvider.open();
          var accountPersist = AccountPersist(
              userId: user.id,
              userImage: user.profileImageUrls.px170x170,
              accessToken: accountResponse.accessToken,
              refreshToken: accountResponse.refreshToken,
              deviceToken: "",
              passWord: "no more",
              name: user.name,
              account: user.account,
              mailAddress: user.mailAddress,
              isPremium: user.isPremium ? 1 : 0,
              xRestrict: user.xRestrict,
              isMailAuthorized: user.isMailAuthorized ? 1 : 0);
          await accountProvider.insert(accountPersist);
          await accountStore.fetch();
          BotToast.showText(text: "Login Success");
          if (Platform.isIOS) pushUntilHome(context);
        } catch (e) {
          LPrinter.d(e);
          BotToast.showText(text: e.toString());
        }
      } else if (link.host.contains("illusts") || link.host.contains("user")) {
        _parseUriContent(context, link);
      }
    } else if (link.scheme.contains("http")) {
      _parseUriContent(context, link);
    } else if (link.scheme == "pixez") {
      _parseUriContent(context, link);
    }
  }

  static void _parseUriContent(BuildContext context, Uri link) {
    if (link.host.contains('illusts')) {
      var idSource = link.pathSegments.last;
      try {
        int id = int.parse(idSource);
        Navigator.of(context, rootNavigator: true)
            .push(MaterialPageRoute(builder: (context) {
          return IllustLightingPage(
            id: id,
          );
        }));
      } catch (e) {}
      return;
    } else if (link.host.contains('user')) {
      var idSource = link.pathSegments.last;
      try {
        int id = int.parse(idSource);
        Navigator.of(context, rootNavigator: true)
            .push(MaterialPageRoute(builder: (context) {
          return UsersPage(
            id: id,
          );
        }));
      } catch (e) {}
      return;
    } else if (link.host.contains('pixiv')) {
      if (link.path.contains("artworks")) {
        List<String> paths = link.pathSegments;
        int index = paths.indexOf("artworks");
        if (index != -1) {
          try {
            int id = int.parse(paths[index + 1]);
            Navigator.of(context, rootNavigator: true)
                .push(MaterialPageRoute(builder: (context) {
              return IllustLightingPage(id: id);
            }));
            return;
          } catch (e) {
            LPrinter.d(e);
          }
        }
      }
      if (link.path.contains("users")) {
        List<String> paths = link.pathSegments;
        int index = paths.indexOf("users");
        if (index != -1) {
          try {
            int id = int.parse(paths[index + 1]);
            Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
                builder: (context) => UsersPage(
                      id: id,
                    )));
          } catch (e) {
            print(e);
          }
        }
      }
      if (link.queryParameters['illust_id'] != null) {
        try {
          var id = link.queryParameters['illust_id'];
          Leader.push(context, IllustLightingPage(id: int.parse(id!)));
          return;
        } catch (e) {}
      }
      if (link.queryParameters['id'] != null) {
        try {
          var id = link.queryParameters['id'];
          if (!link.path.contains("novel"))
            Navigator.of(context, rootNavigator: true)
                .push(MaterialPageRoute(builder: (context) {
              return UsersPage(
                id: int.parse(id!),
              );
            }));
          else
            Navigator.of(context, rootNavigator: true)
                .push(MaterialPageRoute(builder: (context) {
              return NovelViewerPage(
                id: int.parse(id!),
                novelStore: null,
              );
            }));
          return;
        } catch (e) {}
      }
      if (link.pathSegments.length >= 2) {
        String i = link.pathSegments[link.pathSegments.length - 2];
        if (i == "i") {
          try {
            int id = int.parse(link.pathSegments[link.pathSegments.length - 1]);
            Leader.push(context, IllustLightingPage(id: id));
            return;
          } catch (e) {}
        } else if (i == "u") {
          try {
            int id = int.parse(link.pathSegments[link.pathSegments.length - 1]);
            Navigator.of(context, rootNavigator: true)
                .push(MaterialPageRoute(builder: (context) {
              return UsersPage(
                id: id,
              );
            }));
            return;
          } catch (e) {}
        } else if (i == "tags") {
          try {
            String tag = link.pathSegments[link.pathSegments.length - 1];
            Navigator.of(context, rootNavigator: true)
                .push(MaterialPageRoute(builder: (context) {
              return ResultPage(
                word: tag,
              );
            }));
          } catch (e) {}
        }
      }
    }
  }

  static Future<dynamic> pushWithScaffold(context, Widget widget) {
    return Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => Scaffold(
              body: widget,
            )));
  }

  static Future<dynamic> push(context, Widget widget) {
    return Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => Scaffold(
              body: widget,
            )));
  }
}
