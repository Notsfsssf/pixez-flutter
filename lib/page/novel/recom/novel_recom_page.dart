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

import 'package:bot_toast/bot_toast.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:pixez/component/pixez_default_header.dart';
import 'package:pixez/exts.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/models/novel_recom_response.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/novel/component/novel_bookmark_button.dart';
import 'package:pixez/page/novel/component/novel_lighting_store.dart';
import 'package:pixez/page/novel/viewer/novel_viewer.dart';
import 'package:pixez/translation/html_text.dart';
import 'package:pixez/translation/translation_service.dart';
import 'package:pixez/utils/haptic_util.dart';
import 'package:translator/translator.dart';

class NovelRecomPage extends StatefulWidget {
  @override
  _NovelRecomPageState createState() => _NovelRecomPageState();
}

class _NovelRecomPageState extends State<NovelRecomPage>
    with AutomaticKeepAliveClientMixin {
  late NovelLightingStore _store;
  late EasyRefreshController _easyRefreshController;

  /// 卡片译文（novelId → 结果）。状态挂在页面上而不是卡片 widget 里：
  /// 推荐流滑出屏幕再滑回来会重建卡片，放 widget 里等于每次重翻一遍。
  final Map<int, _CardTranslation> _cardTranslations = {};

  /// 端侧模型一次只跑一个请求，多张卡同时点只会排队干等——一次一张，
  /// 已经在翻时给句提示，而不是让用户对着两个转圈发呆。
  bool _cardTranslating = false;

  @override
  void initState() {
    _easyRefreshController = EasyRefreshController(
        controlFinishLoad: true, controlFinishRefresh: true);
    _store = NovelLightingStore(
        () => apiClient.getNovelRecommended(), _easyRefreshController);
    super.initState();
  }

  @override
  void dispose() {
    _easyRefreshController.dispose();
    super.dispose();
  }

  Widget _buildFirstRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            child: Padding(
              child: Text(
                I18n.of(context).recommend,
                style: TextStyle(
                    color: Theme.of(context).textTheme.titleLarge!.color),
              ),
              padding: EdgeInsets.only(left: 8.0, bottom: 10.0),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return EasyRefresh.builder(
      header: PixezDefault.header(context),
      onRefresh: () => _store.fetch(),
      onLoad: () => _store.next(),
      controller: _easyRefreshController,
      callRefreshOverOffset: 10,
      refreshOnStart: true,
      childBuilder: (context, physics) => Observer(builder: (context) {
        return CustomScrollView(
          physics: physics,
          slivers: [
            SliverAppBar(
              elevation: 0.0,
              titleSpacing: 0.0,
              automaticallyImplyLeading: false,
              backgroundColor: Colors.transparent,
              title: _buildFirstRow(context),
            ),
            if (_store.novels.isNotEmpty) _buildSliverList(),
          ],
        );
      }),
    );
  }

  SliverList _buildSliverList() {
    _store.novels.removeWhere((element) => element.novel?.hateByUser() == true);
    return SliverList(
        delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
      Novel novel = _store.novels[index].novel!;
      return _buildItem(context, novel, index);
    }, childCount: _store.novels.length));
  }

  /// 卡片翻译：标题 + 简介开头。
  ///
  /// 只翻简介前 240 字：卡片最多显示三行，整段简介常上千字，端侧跑一遍要
  /// 好几分钟，翻完也没人读。
  Future<void> _toggleCardTranslation(Novel novel) async {
    final id = novel.id;
    final current = _cardTranslations[id];
    if (current?.loading ?? false) return;
    if (current != null && current.hasTranslation) {
      // 已经有译文：在原文 / 译文之间来回切，不重复请求。
      setState(() {
        _cardTranslations[id] = current.copyWith(showing: !current.showing);
      });
      return;
    }
    if (_cardTranslating) {
      BotToast.showText(text: '正在翻译上一张卡片，请稍候');
      return;
    }
    setState(() {
      _cardTranslating = true;
      _cardTranslations[id] = const _CardTranslation(loading: true);
    });
    final service = TranslationService.instance;
    service.prewarm(); // 端侧：先把权重热起来，第一张卡不至于干等加载
    try {
      final translator = await service.getTextTranslator();
      final request = await service.buildRequest();
      final titleSource = novel.title.trim();
      final captionSource = _captionPreview(novel.caption);
      final titleZh = titleSource.isEmpty
          ? null
          : await translator.translateText(titleSource, request);
      final captionZh = captionSource.isEmpty
          ? null
          : await translator.translateText(captionSource, request);
      if (!mounted) return;
      final result = _CardTranslation(title: titleZh, caption: captionZh);
      setState(() {
        _cardTranslations[id] = result;
      });
      if (!result.hasTranslation) {
        BotToast.showText(text: I18n.of(context).translation_failed);
      }
    } catch (e) {
      if (!mounted) return;
      // 失败要退回原文：留一张「点了没反应」的卡比报错更让人困惑。
      setState(() => _cardTranslations.remove(id));
      BotToast.showText(text: _friendlyError(e));
    } finally {
      _cardTranslating = false;
    }
  }

  /// 简介取纯文本前 240 字，尽量在句末断开（供卡片显示三行）。
  String _captionPreview(String caption) {
    final text = stripHtmlToText(caption).trim();
    if (text.isEmpty) return '';
    final pieces = splitTextForModel(text, maxChars: 240);
    return pieces.isEmpty ? '' : pieces.first.trim();
  }

  /// 底层异常翻成一句人话（SDK 原文太长，一行 toast 放不下）。
  String _friendlyError(Object e) {
    final text = '$e';
    if (text.contains('too long') ||
        text.contains('n_ctx') ||
        text.contains('context')) {
      return '这段简介超出端侧模型上下文长度，请打开小说后再翻';
    }
    return text;
  }

  Widget _buildCardTranslateButton(BuildContext context, Novel novel) {
    final trans = _cardTranslations[novel.id];
    if (trans?.loading ?? false) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 10.0),
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    final scheme = Theme.of(context).colorScheme;
    // 正在显示译文时点亮图标：否则用户分不清现在读的是原文还是译文。
    final color = (trans?.showing ?? false)
        ? scheme.primary
        : Theme.of(context).textTheme.labelSmall!.color!.withValues(alpha: 0.7);
    return IconButton(
      tooltip: I18n.of(context).translation,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
      onPressed: () => _toggleCardTranslation(novel),
      icon: Icon(Icons.translate, size: 18, color: color),
    );
  }

  Widget _buildItem(BuildContext context, Novel novel, int index) {
    final trans = _cardTranslations[novel.id];
    final showing = trans?.showing ?? false;
    final translatedTitle = showing ? trans?.title : null;
    // 标题直接换掉而不是原文下面再挂一行：卡片只有三行高，两行标题会把
    // 作者 / 标签 / 简介全挤走。
    final title = (translatedTitle?.isNotEmpty ?? false)
        ? translatedTitle!
        : novel.title;
    final translatedCaption = showing ? trans?.caption : null;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: InkWell(
        onTap: () {
          HapticUtil.selectionClick();
          Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
              builder: (BuildContext context) => NovelViewerPage(
                    id: novel.id,
                    novelStore: _store.novels[index],
                  )));
        },
        child: Card(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 5,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: PixivImage(
                        novel.imageUrls.medium,
                        width: 80,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0, left: 8.0),
                            child: Text(
                              title,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyLarge,
                              maxLines: 3,
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  novel.user.name,
                                  maxLines: 1,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 8),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.article,
                                        size: 12,
                                        color: Theme.of(context)
                                            .textTheme
                                            .labelSmall!
                                            .color,
                                      ),
                                      SizedBox(
                                        width: 2,
                                      ),
                                      Text(
                                        '${novel.textLength}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall,
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 2, // gap between adjacent chips
                              runSpacing: 0,
                              children: [
                                for (var f in novel.tags)
                                  Text(
                                    f.name,
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  )
                              ],
                            ),
                          ),
                          // 译文简介：卡片原本只有标题 / 作者 / 标签，看不出
                          // 「这本讲什么」；翻完顺手把前三行铺上来。
                          if (translatedCaption != null &&
                              translatedCaption.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 4.0,
                                left: 8.0,
                                right: 8.0,
                              ),
                              child: Text(
                                translatedCaption,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall!
                                    .copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ),
                          Container(
                            height: 8.0,
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    NovelBookmarkButton(novel: novel),
                    Text('${novel.totalBookmarks}',
                        style: Theme.of(context).textTheme.bodySmall),
                    _buildCardTranslateButton(context, novel)
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

/// 单张推荐卡片的译文状态。
class _CardTranslation {
  final String? title;
  final String? caption;
  final bool loading;

  /// 当前是否显示译文（false = 显示原文，译文仍在缓存里，随时切回）。
  final bool showing;

  const _CardTranslation({
    this.title,
    this.caption,
    this.loading = false,
    this.showing = true,
  });

  bool get hasTranslation =>
      (title?.isNotEmpty ?? false) || (caption?.isNotEmpty ?? false);

  _CardTranslation copyWith({bool? showing}) => _CardTranslation(
    title: title,
    caption: caption,
    loading: loading,
    showing: showing ?? this.showing,
  );
}
