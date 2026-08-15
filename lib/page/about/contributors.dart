import 'dart:io';
import 'dart:math';

import 'package:bot_toast/bot_toast.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluentui;
import 'package:material_ui/material_ui.dart' as material;
import 'package:flutter/widgets.dart';
import 'package:pixez/fluent/component/pixiv_image.dart' as fluentui;
import 'package:pixez/component/pixiv_image.dart' as material;
import 'package:pixez/constants.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/recommend.dart';
import 'package:pixez/network/api_client.dart';

/// Safe Mode (?
final bool _safeMode = Platform.isIOS || Constants.isGooglePlay;

get _showBottomSheet {
  if (Constants.isFluent)
    return ({
      required BuildContext context,
      required WidgetBuilder builder,
      Color? backgroundColor,
      double? elevation,
      ShapeBorder? shape,
      Clip? clipBehavior,
      BoxConstraints? constraints,
      bool? enableDrag,
      AnimationController? transitionAnimationController,
    }) =>
        fluentui.showDialog(
          context: context,
          barrierDismissible: true,
          builder: (context) => Padding(
            padding: EdgeInsets.all(128),
            child: builder(context),
          ),
        );
  else
    return material.showBottomSheet;
}

List<Contributor> contributors = [
  Contributor(
    'Tragic Life',
    'https://avatars.githubusercontent.com/u/16817202?v=4',
    'https://github.com/TragicLifeHu',
    '🌍',
    onPressed: (context) async {
      //Tragic Life:輪播凱留TAG 10000+收藏的圖
      if (accountStore.now == null) return;
      if (Platform.isIOS) return;

      final response =
          await apiClient.getSearchIllust("キャル(プリコネ) 10000users入り");
      Recommend recommend = Recommend.fromJson(response.data);
      if (recommend.illusts.isEmpty) return;
      final targetIllusts = _safeMode || userSetting.hIsNotAllow
          ? recommend.illusts
              .where((element) => !element.tags.any((i) => i.name == "R-18"))
              .toList()
          : recommend.illusts;
      if (targetIllusts.isEmpty) return;
      final url = targetIllusts[Random().nextInt(targetIllusts.length)]
          .imageUrls
          .medium;

      _showBottomSheet(
        context: context,
        builder: (context) {
          return SafeArea(
            child: Constants.isFluent
                ? fluentui.PixivImage(url)
                : material.PixivImage(url),
          );
        },
      );
    },
  ),
  Contributor(
    'Skimige',
    'https://avatars.githubusercontent.com/u/9017470?v=4',
    'https://xyx.moe/',
    '📖',
    onPressed: (context) async {
      //☆:“都给我去看 FAQ！”
      String text = _safeMode ? "R！T！F！M！" : "Read The Fucking Manual!";
      BotToast.showText(text: text);
    },
  ),
  Contributor(
    'Xian',
    'https://avatars.githubusercontent.com/u/34748039?v=4',
    'https://github.com/itzXian',
    '🌍',
    onPressed: (context) async {
      //XIAN:随机加载一张色图
      if (accountStore.now == null) return;
      if (_safeMode) return;
      if (userSetting.hIsNotAllow) {
        _showBottomSheet(
            context: context,
            builder: (context) {
              return SafeArea(
                child: Image.asset(Constants.no_h),
              );
            });
        return;
      }
      final response = await apiClient.getIllustRanking('day_r18', null);
      Recommend recommend = Recommend.fromJson(response.data);
      _showBottomSheet(
        context: context,
        builder: (context) {
          final url = recommend.illusts[Random().nextInt(10)].imageUrls.medium;
          return SafeArea(
            child: Constants.isFluent
                ? fluentui.PixivImage(url)
                : material.PixivImage(url),
          );
        },
      );
    },
  ),
  Contributor(
    'karin722',
    'https://avatars.githubusercontent.com/u/54385201?v=4',
    'http://ivtune.net/',
    '🌍',
  ),
  Contributor(
    'Romani-Archman',
    'https://avatars.githubusercontent.com/u/68731023?v=4',
    'http://archman.fun/',
    '📖',
    onPressed: (context) async {
      //GC:摸一摸可爱的鱼
      if (_safeMode) {
        //摸不了,来点tips
        const RA_Tips = const [
          "FAQ是个好东西",
          "想摸鱼,但摸不了",
          "为啥他们都会飞镖",
          "正在开启青壮年模式(假的",
          "别戳了,会怀孕的",
          "我有一个很好的想法,但这写不下",
        ];
        BotToast.showText(text: RA_Tips[Random().nextInt(7)]);
      } else {
        _showBottomSheet(
          context: context,
          builder: (context) {
            return SafeArea(
              child: Image.asset(
                'assets/images/fish.gif',
                fit: BoxFit.cover,
              ),
            );
          },
        );
      }
    },
  ),
  Contributor(
    'Henry-ZHR',
    'https://avatars.githubusercontent.com/u/51886614?v=4',
    'https://github.com/Henry-ZHR',
    '💻',
  ),
  Contributor(
    'Takase',
    'https://avatars.githubusercontent.com/u/20792268?v=4',
    'https://github.com/takase1121',
    '🌍',
  ),
  Contributor(
    'ChsBuffer',
    'https://avatars.githubusercontent.com/u/33744752?v=4',
    'https://github.com/chsbuffer',
    '💻',
  ),
  Contributor(
    "媛天徵",
    "https://avatars.githubusercontent.com/u/64569368?v=4",
    'https://github.com/YooTynChi',
    '🌍',
  ),
  Contributor(
    "Scighost",
    "https://avatars.githubusercontent.com/u/61003590?v=4",
    'https://github.com/Scighost',
    '💻',
  ),
  Contributor(
    "sheason2019",
    "https://avatars.githubusercontent.com/u/73812146?v=4",
    'https://github.com/sheason2019',
    '💻',
  ),
  Contributor(
    "frg2089",
    "https://avatars.githubusercontent.com/u/42184238?v=4",
    'https://github.com/frg2089',
    '💻🪟',
  ),
];

class Contributor {
  final String name;
  final String avatar;
  final String url;
  final String content;
  final Function(BuildContext context)? onPressed;

  Contributor(
    this.name,
    this.avatar,
    this.url,
    this.content, {
    this.onPressed,
  });
}
