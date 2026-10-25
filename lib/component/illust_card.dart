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

import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/component/null_hero.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/component/star_icon.dart';
import 'package:pixez/constants.dart';
import 'package:pixez/er/illust_cacher.dart';
import 'package:pixez/er/lprinter.dart';
import 'package:pixez/er/prefer.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/lighting/lighting_store.dart';
import 'package:pixez/main.dart';
import 'package:pixez/page/picture/illust_lighting_page.dart';
import 'package:pixez/page/picture/illust_store.dart';
import 'package:pixez/page/picture/picture_list_page.dart';
import 'package:pixez/page/picture/tag_for_illust_page.dart';
import 'package:pixez/page/series/illust_series_page.dart';
import 'package:pixez/translation/thumbnail_translation.dart';
import 'package:pixez/translation/widgets/inline_translation_overlay.dart';
import 'package:pixez/utils/haptic_util.dart';

class IllustCard extends StatefulWidget {
  final IllustStore store;
  final List<IllustStore>? iStores;
  final bool needToBan;
  final LightingStore lightingStore;

  IllustCard({
    required this.store,
    required this.lightingStore,
    this.iStores,
    this.needToBan = false,
  });

  @override
  _IllustCardState createState() => _IllustCardState();
}

class _IllustCardState extends State<IllustCard> {
  late IllustStore store;
  late List<IllustStore>? iStores;
  late String tag;
  late LightingStore _lightingStore;

  /// 该卡片当前是否显示原文（就地翻译完成后点击角标切换）。
  bool _showOriginal = false;

  @override
  void initState() {
    store = widget.store;
    iStores = widget.iStores;
    _lightingStore = widget.lightingStore;
    tag = this.hashCode.toString();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant IllustCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    store = widget.store;
    iStores = widget.iStores;
    _lightingStore = widget.lightingStore;
  }

  @override
  Widget build(BuildContext context) {
    if (userSetting.hIsNotAllow)
      for (int i = 0; i < store.illusts!.tags.length; i++) {
        if (store.illusts!.tags[i].name.startsWith('R-18')) {
          return InkWell(
            onTap: () => _buildTap(context),
            onLongPress: () => _onLongPressSave(),
            child: Card(
              margin: EdgeInsets.all(8.0),
              elevation: 8.0,
              clipBehavior: Clip.antiAlias,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
              ),
              child: Image.asset(Constants.no_h),
            ),
          );
        }
      }
    return _buildInkWell(context);
  }

  _onLongPressSave() async {
    HapticUtil.heavy();
    if (userSetting.longPressSaveConfirm) {
      final result = await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(I18n.of(context).save),
            content: Text(store.illusts?.title ?? ""),
            actions: <Widget>[
              TextButton(
                child: Text(I18n.of(context).cancel),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              TextButton(
                child: Text(I18n.of(context).ok),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          );
        },
      );
      if (!result) {
        return;
      }
    }
    saveStore.saveImage(store.illusts!);
    if (userSetting.starAfterSave && (store.state == 0)) {
      bool success = await store.star(
        restrict: userSetting.defaultPrivateLike ? "private" : "public",
      );
      if (success && userSetting.followAfterStar) {
        await store.followAfterStar();
      }
    }
  }

  Future _buildTap(BuildContext context) {
    return Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) {
          return PictureListPage(
            iStores: iStores!,
            store: store,
            lightingStore: _lightingStore,
            heroString: tag,
          );
        },
      ),
    );
  }

  Widget cardText() {
    if (store.illusts!.type != "illust") {
      return Text(store.illusts!.type, style: TextStyle(color: Colors.white));
    }
    if (store.illusts!.metaPages.isNotEmpty) {
      return Text(
        store.illusts!.metaPages.length.toString(),
        style: TextStyle(color: Colors.white),
      );
    }
    return Text('');
  }

  /// 卡片显示的预览图 URL（跟随「信息流预览画质」设置）。
  String _previewUrl() => switch (userSetting.feedPreviewQuality) {
    0 => store.illusts!.imageUrls.medium,
    1 => store.illusts!.imageUrls.large,
    2 =>
      store.illusts!.metaSinglePage?.originalImageUrl ??
          store.illusts!.metaPages[0].imageUrls!.original,
    _ => store.illusts!.imageUrls.medium,
  };

  /// 就地翻译（OCR）用的图：优先 large——比 medium 清晰，比 original 省内存。
  ///
  /// 译文坐标记录的是这张图解码后的真实像素尺寸，与卡片显示尺寸无关，
  /// 所以切换预览画质不会让译文错位。
  String _translationUrl() {
    final illusts = store.illusts!;
    if (illusts.imageUrls.large.isNotEmpty) return illusts.imageUrls.large;
    return illusts.metaSinglePage?.originalImageUrl ??
        (illusts.metaPages.isNotEmpty
            ? illusts.metaPages[0].imageUrls?.original ?? ''
            : '');
  }

  Widget _buildPic(String tag, bool tooLong, String url) {
    final quality = IllustQualityExtension.fromValue(
      userSetting.feedPreviewQuality,
    );
    return tooLong
        ? NullHero(
            tag: tag,
            child: PixivImage(
              store.illusts!.imageUrls.squareMedium,
              fit: BoxFit.fitWidth,
            ),
          )
        : NullHero(
            tag: tag,
            child: PixivImage(
              url,
              fit: BoxFit.fitWidth,
              cacheHeaderData: PixEzCacheHeaderData(key: tag, quality: quality),
            ),
          );
  }

  Widget _buildInkWell(BuildContext context) {
    var tooLong =
        store.illusts!.height.toDouble() / store.illusts!.width.toDouble() > 3;
    var radio = (tooLong)
        ? 1.0
        : store.illusts!.width.toDouble() / store.illusts!.height.toDouble();
    final previewUrl = _previewUrl();
    final translationUrl = _translationUrl();
    return Card(
      margin: EdgeInsets.all(8.0),
      clipBehavior: Clip.antiAlias,
      color: Theme.of(context).colorScheme.surface,
      child: _buildAnimationWraper(
        context,
        Column(
          children: <Widget>[
            AspectRatio(
              aspectRatio: radio,
              child: Stack(
                children: [
                  Positioned.fill(child: _buildPic(tag, tooLong, previewUrl)),
                  // 就地翻译覆盖层：块坐标从原图像素换算到卡片显示尺寸，
                  // 因为它在卡片内部，滚动时自然跟随，不需要全局浮层。
                  if (!tooLong)
                    Positioned.fill(
                      child: AnimatedBuilder(
                        animation: ThumbnailTranslationService.instance,
                        builder: (context, _) {
                          final entry = ThumbnailTranslationService.instance
                              .entryFor(translationUrl);
                          if (entry.blocks.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          return InlineTranslationOverlay(
                            blocks: entry.blocks,
                            originalSize: entry.originalSize,
                            showOriginal: _showOriginal,
                            // 点任一块切换整图译文 / 原文：卡片太小，
                            // 逐块切换容易误触。
                            onBlockTap: (_) =>
                                setState(() => _showOriginal = !_showOriginal),
                          );
                        },
                      ),
                    ),
                  Positioned(
                    top: 5.0,
                    right: 5.0,
                    child: Row(
                      children: [
                        if (userSetting.feedAIBadge &&
                            store.illusts!.illustAIType == 2)
                          _buildAIBadge(),
                        if (!tooLong) _buildTranslateChip(translationUrl),
                        _buildVisibility(),
                      ],
                    ),
                  ),
                  // Positioned(
                  //   top: 0,
                  //   left: 0,
                  //   child: CustomPaint(
                  //     size: Size(36, 36),
                  //     painter: TrianglePainter(),
                  //   ),
                  // ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBottom(context),
                if (store.illusts?.series != null) ...[
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              IllustSeriesPage(id: store.illusts!.series!.id),
                        ),
                      );
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      margin: EdgeInsets.only(left: 8, bottom: 4),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${store.illusts?.series?.title ?? ''}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAIBadge() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 4.0),
        child: Text("AI", style: TextStyle(color: Colors.white)),
      ),
    );
  }

  /// 翻译角标：点击翻译 / 切换译文原文，长按丢弃译文重新翻译。
  ///
  /// 只翻「当前这一张」，不做信息流自动翻译：端侧一张图要跑 OCR + 多批
  /// 推理（十几秒），自动翻整屏会把队列彻底堵死。
  Widget _buildTranslateChip(String url) {
    final service = ThumbnailTranslationService.instance;
    return AnimatedBuilder(
      animation: service,
      builder: (context, _) {
        final entry = service.entryFor(url);
        final running =
            service.isRunning(url) ||
            entry.state == ThumbTranslationState.running;
        final done = entry.state == ThumbTranslationState.done;
        final failed =
            entry.state == ThumbTranslationState.error ||
            entry.state == ThumbTranslationState.empty;
        final label = failed
            ? '!'
            : done
            ? (_showOriginal ? '原' : '译')
            : '译';
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: running
              ? null
              : () {
                  if (done) {
                    setState(() => _showOriginal = !_showOriginal);
                    return;
                  }
                  if (entry.state == ThumbTranslationState.error) {
                    // 失败原因（模型未安装 / 解码失败等）直接弹出来，
                    // 否则角标只有一个「!」没法排障。
                    final reason = entry.error ?? '';
                    BotToast.showText(
                      text: reason.length > 160
                          ? reason.substring(0, 160)
                          : reason,
                    );
                    service.forget(url);
                    return;
                  }
                  if (entry.state == ThumbTranslationState.empty) {
                    service.forget(url);
                  }
                  service.translate(url);
                },
          onLongPress: running
              ? null
              : () {
                  if (!done) return;
                  HapticUtil.heavy();
                  service.forget(url);
                  if (_showOriginal) setState(() => _showOriginal = false);
                },
          child: Container(
            margin: EdgeInsets.only(left: 4.0),
            padding: const EdgeInsets.symmetric(
              vertical: 1.0,
              horizontal: 6.0,
            ),
            decoration: BoxDecoration(
              color: done
                  ? Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.9)
                  : Colors.black26,
              borderRadius: BorderRadius.all(Radius.circular(4.0)),
            ),
            child: running
                ? SizedBox(
                    width: 11,
                    height: 11,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.4,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    label,
                    style: TextStyle(color: Colors.white, fontSize: 11),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildAnimationWraper(BuildContext context, Widget child) {
    return InkWell(
      onLongPress: () {
        _buildLongPressToSaveHint();
      },
      onTap: () {
        _buildInkTap(context, tag);
      },
      child: child,
    );
  }

  _buildLongPressToSaveHint() async {
    if (Platform.isIOS) {
      final firstLongPress = await Prefer.getBool("first_long_press") ?? true;
      if (firstLongPress) {
        await Prefer.setBool("first_long_press", false);
        await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('长按保存'),
              content: Text('长按卡片将会保存插画到相册'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(I18n.of(context).ok),
                ),
              ],
            );
          },
        );
      }
    }
    _onLongPressSave();
  }

  Future<void> _buildInkTap(BuildContext context, String heroTag) async {
    HapticUtil.selectionClick();
    await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) {
          if (iStores != null) {
            return PictureListPage(
              heroString: heroTag,
              store: store,
              lightingStore: _lightingStore,
              iStores: iStores!,
            );
          }
          return IllustLightingPage(
            id: store.illusts!.id,
            heroString: heroTag,
            store: store,
          );
        },
      ),
    );
  }

  Widget _buildBottom(BuildContext context) {
    return Container(
      child: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(
              left: 8.0,
              right: 36.0,
              top: 4,
              bottom: 4,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  store.illusts!.title,
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                  style: Theme.of(context).textTheme.bodyMedium,
                  strutStyle: StrutStyle(forceStrutHeight: true, leading: 0),
                ),
                Text(
                  store.illusts!.user.name,
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                  style: Theme.of(context).textTheme.bodySmall,
                  strutStyle: StrutStyle(forceStrutHeight: true, leading: 0),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              child: Observer(
                builder: (_) {
                  return StarIcon(state: store.state);
                },
              ),
              onTap: () async {
                if (userSetting.saveAfterStar && (store.state == 0)) {
                  saveStore.saveImage(store.illusts!);
                }
                // TODO: 添加配置项 开关和过滤器
                final List<String>? tags;
                if (userSetting.autoTagWhenStar) {
                  final filters = [RegExp(r"\d+users入り")];
                  tags = store.illusts?.tags
                      .map((tag) => tag.name)
                      .where(
                        (tag) => !filters.any((regex) => regex.hasMatch(tag)),
                      )
                      .toList();
                } else {
                  tags = null;
                }
                bool success = await store.star(
                  restrict: userSetting.defaultPrivateLike
                      ? "private"
                      : "public",
                  tags: tags,
                );
                if (success && userSetting.followAfterStar) {
                  bool followSuccess = await store.followAfterStar();
                  if (followSuccess) {
                    BotToast.showText(
                      text:
                          "${store.illusts!.user.name} ${I18n.of(context).followed}",
                    );
                  }
                }
              },
              onLongPress: () async {
                HapticUtil.heavy();
                final result = await showModalBottomSheet(
                  context: context,
                  clipBehavior: Clip.hardEdge,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  constraints: BoxConstraints.expand(
                    height: MediaQuery.of(context).size.height * .618,
                  ),
                  isScrollControlled: true,
                  builder: (_) => TagForIllustPage(id: store.illusts!.id),
                );
                if (result?.isNotEmpty ?? false) {
                  LPrinter.d(result);
                  String restrict = result['restrict'];
                  List<String>? tags = result['tags'];
                  store.star(restrict: restrict, tags: tags, force: true);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisibility() {
    return Visibility(
      visible:
          store.illusts!.type != "illust" ||
          store.illusts!.metaPages.isNotEmpty,
      child: Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: EdgeInsets.all(4.0),
          child: Container(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 0.0,
                horizontal: 4.0,
              ),
              child: cardText(),
            ),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.all(Radius.circular(4.0)),
            ),
          ),
        ),
      ),
    );
  }
}

class TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.yellow
      ..style = PaintingStyle.fill;

    var path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(0, size.height);
    path.lineTo(0, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
