// import 'dart:convert';
// import 'dart:io';

// import 'package:bot_toast/bot_toast.dart';
// import 'package:dio/dio.dart';
// import 'package:fluent_ui/fluent_ui.dart';
// import 'package:pixez/er/lprinter.dart';
// import 'package:pixez/fluent/page/hello/fluent_hello_page.dart';
// import 'package:pixez/fluent/page/hello/setting/save_eval_page.dart';
// import 'package:pixez/fluent/page/picture/illust_lighting_page.dart';
// import 'package:pixez/fluent/page/search/result_page.dart';
// import 'package:pixez/fluent/page/soup/soup_page.dart';
// import 'package:pixez/fluent/page/user/users_page.dart';
// import 'package:pixez/i18n.dart';
// import 'package:pixez/main.dart';
// import 'package:pixez/models/account.dart';
// import 'package:pixez/network/oauth_client.dart';
// import 'package:pixez/page/novel/viewer/novel_viewer.dart';
// import 'package:url_launcher/url_launcher.dart';

// class FluentLeader {
//   static Future<void> pushUntilHome(BuildContext context) async {
//     Navigator.of(context).pushAndRemoveUntil(
//       FluentPageRoute(
//         builder: (context) => FluentHelloPage(),
//       ),
//       // ignore: unnecessary_null_comparison
//       (route) => route == null,
//     );
//   }

//   static Future<void> pushWithUri(BuildContext context, Uri link) async {
//     if (link.host == "eval" && link.scheme == "pixez") {
//       showDialog(
//           context: context,
//           builder: (context) => SaveEvalPage(
//                 eval: link.queryParameters["code"] != null
//                     ? String.fromCharCodes(
//                         base64Decode(link.queryParameters["code"]!))
//                     : null,
//               ),
//           useRootNavigator: false);
//       return;
//     }
//     if (link.host == "pixiv.me") {
//       try {
//         BotToast.showText(text: "Pixiv me...");
//         var dio = Dio();
//         Response response = await dio.getUri(link);
//         if (response.isRedirect == true) {
//           Uri source = response.realUri;
//           LPrinter.d("here we go pixiv me:" + source.toString());
//           pushWithUri(context, source);
//           return;
//         }
//       } catch (e) {
//         try {
//           launchUrl(link);
//         } catch (e) {}
//       }
//       return;
//     }
//     if (link.host.contains("pixivision.net")) {
//       FluentLeader.push(
//         context,
//         SoupPage(
//             url: link.toString().replaceAll("pixez://", "https://"),
//             spotlight: null),
//         icon: const Icon(FluentIcons.image_pixel),
//         title: Text("${I18n.of(context).spotlight}"),
//       );
//       return;
//     }
//     if (link.scheme == "pixiv") {
//       if (link.host.contains("account")) {
//         try {
//           BotToast.showText(text: "working....");
//           String code = link.queryParameters['code']!;
//           LPrinter.d("here we go:" + code);
//           Response response = await oAuthClient.code2Token(code);
//           AccountResponse accountResponse =
//               Account.fromJson(response.data).response;
//           final user = accountResponse.user;
//           AccountProvider accountProvider = new AccountProvider();
//           await accountProvider.open();
//           var accountPersist = AccountPersist(
//               userId: user.id,
//               userImage: user.profileImageUrls.px170x170,
//               accessToken: accountResponse.accessToken,
//               refreshToken: accountResponse.refreshToken,
//               deviceToken: "",
//               passWord: "no more",
//               name: user.name,
//               account: user.account,
//               mailAddress: user.mailAddress,
//               isPremium: user.isPremium ? 1 : 0,
//               xRestrict: user.xRestrict,
//               isMailAuthorized: user.isMailAuthorized ? 1 : 0);
//           await accountProvider.insert(accountPersist);
//           await accountStore.fetch();
//           BotToast.showText(text: "Login Success");
//           if (Platform.isIOS) pushUntilHome(context);
//         } catch (e) {
//           LPrinter.d(e);
//           BotToast.showText(text: e.toString());
//         }
//       } else if (link.host.contains("illusts") ||
//           link.host.contains("user") ||
//           link.host.contains("novel")) {
//         _parseUriContent(context, link);
//       }
//     } else if (link.scheme.contains("http")) {
//       _parseUriContent(context, link);
//     } else if (link.scheme == "pixez") {
//       _parseUriContent(context, link);
//     }
//   }

//   static void _parseUriContent(BuildContext context, Uri link) {
//     if (link.host.contains('illusts')) {
//       var idSource = link.pathSegments.last;
//       try {
//         int id = int.parse(idSource);
//         FluentLeader.push(
//           context,
//           IllustLightingPage(id: id),
//           icon: Icon(FluentIcons.picture),
//           title: Text(I18n.of(context).illust_id + ': $id'),
//         );
//       } catch (e) {}
//       return;
//     } else if (link.host.contains('user')) {
//       var idSource = link.pathSegments.last;
//       try {
//         int id = int.parse(idSource);
//         FluentLeader.push(
//           context,
//           UsersPage(id: id),
//           title: Text(I18n.of(context).painter_id + ': ${id}'),
//           icon: Icon(FluentIcons.account_browser),
//         );
//       } catch (e) {}
//       return;
//     } else if (link.host.contains("novel")) {
//       try {
//         int id = int.parse(link.pathSegments.last);
//         Navigator.of(context).push(PixEzPageRoute(builder: (context) {
//           return NovelViewerPage(id: id);
//         }));
//         return;
//       } catch (e) {
//         LPrinter.d(e);
//       }
//     } else if (link.host.contains('pixiv')) {
//       if (link.path.contains("artworks")) {
//         List<String> paths = link.pathSegments;
//         int index = paths.indexOf("artworks");
//         if (index != -1) {
//           try {
//             int id = int.parse(paths[index + 1]);
//             FluentLeader.push(
//               context,
//               IllustLightingPage(id: id),
//               icon: Icon(FluentIcons.picture),
//               title: Text(I18n.of(context).illust_id + ': $id'),
//             );
//             return;
//           } catch (e) {
//             LPrinter.d(e);
//           }
//         }
//       }
//       if (link.path.contains("users")) {
//         List<String> paths = link.pathSegments;
//         int index = paths.indexOf("users");
//         if (index != -1) {
//           try {
//             int id = int.parse(paths[index + 1]);
//             FluentLeader.push(
//               context,
//               UsersPage(id: id),
//               title: Text(I18n.of(context).painter_id + ': ${id}'),
//               icon: Icon(FluentIcons.account_browser),
//             );
//           } catch (e) {
//             print(e);
//           }
//         }
//       }
//       if (link.queryParameters['illust_id'] != null) {
//         try {
//           var id = link.queryParameters['illust_id'];
//           FluentLeader.push(
//             context,
//             IllustLightingPage(id: int.parse(id!)),
//             icon: Icon(FluentIcons.picture),
//             title: Text(I18n.of(context).illust_id + ': $id'),
//           );
//           return;
//         } catch (e) {}
//       }
//       if (link.queryParameters['id'] != null) {
//         try {
//           var id = link.queryParameters['id'];
//           if (!link.path.contains("novel"))
//             FluentLeader.push(
//               context,
//               UsersPage(id: int.parse(id!)),
//               title: Text(I18n.of(context).painter_id + ': ${id}'),
//               icon: Icon(FluentIcons.account_browser),
//             );
//           else
//             Navigator.of(context).push(PixEzPageRoute(builder: (context) {
//               return NovelViewerPage(
//                 id: int.parse(id!),
//                 novelStore: null,
//               );
//             }));
//           return;
//         } catch (e) {}
//       }
//       if (link.pathSegments.length >= 2) {
//         String i = link.pathSegments[link.pathSegments.length - 2];
//         if (i == "i") {
//           try {
//             int id = int.parse(link.pathSegments[link.pathSegments.length - 1]);
//             FluentLeader.push(
//               context,
//               IllustLightingPage(id: id),
//               icon: Icon(FluentIcons.picture),
//               title: Text(I18n.of(context).illust_id + ': $id'),
//             );
//             return;
//           } catch (e) {}
//         } else if (i == "u") {
//           try {
//             int id = int.parse(link.pathSegments[link.pathSegments.length - 1]);
//             FluentLeader.push(
//               context,
//               UsersPage(id: id),
//               title: Text(I18n.of(context).painter_id + ': ${id}'),
//               icon: Icon(FluentIcons.account_browser),
//             );
//             return;
//           } catch (e) {}
//         } else if (i == "tags") {
//           try {
//             String tag = link.pathSegments[link.pathSegments.length - 1];
//             FluentLeader.push(
//               context,
//               ResultPage(word: tag),
//               icon: const Icon(FluentIcons.search),
//               title: Text('搜索 ${tag}'),
//             );
//           } catch (e) {}
//         }
//       }
//     }
//   }

//   static Future<dynamic> pushWithScaffold(context, Widget widget,
//       {Widget? icon, Widget? title}) {
//     return FluentLeader.push(
//       context,
//       ScaffoldPage(content: widget),
//       icon: icon,
//       title: title,
//     );
//   }

//   static Future<dynamic> push(
//     BuildContext context,
//     Widget widget, {
//     Widget? icon,
//     Widget? title,
//     bool forceSkipWrap = false,
//   }) {
//     final _final = forceSkipWrap
//         ? widget
//         : widget is ScaffoldPage
//             ? widget
//             : ScaffoldPage(
//                 content: widget,
//                 padding: EdgeInsets.all(0.0),
//               );

//     var state = context.findAncestorStateOfType<FluentHelloPageState>();
//     if (state == null) state = FluentHelloPageState.state;
//     assert(state != null);
//     if (icon == null || title == null) {
//       debugPrint('icon: $icon');
//       debugPrint('title: $title');
//       debugPrintStack();
//     }
//     return state!.push(
//       context,
//       PixEzPageRoute(
//         builder: (_) => _final,
//         icon: icon ?? const Icon(FluentIcons.unknown),
//         title: title ?? Text(I18n.of(context).undefined),
//       ),
//     );
//   }
// }
