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

import 'dart:ffi';

import 'package:bot_toast/bot_toast.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/clipboard_plugin.dart';
import 'package:pixez/component/null_hero.dart';
import 'package:pixez/component/star_icon.dart';
import 'package:pixez/constants.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/er/lprinter.dart';
import 'package:pixez/fluent/component/pixez_button.dart';
import 'package:pixez/fluent/component/pixiv_image.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/lighting/lighting_store.dart';
import 'package:pixez/main.dart';
import 'package:pixez/fluent/page/picture/illust_lighting_page.dart';
import 'package:pixez/fluent/page/picture/picture_list_page.dart';
import 'package:pixez/fluent/page/picture/tag_for_illust_page.dart';
import 'package:pixez/page/picture/illust_store.dart';
import 'context_menu.dart';

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
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ContextMenu(
      child: _build(context),
      items: [
        MenuFlyoutItem(
          leading: Observer(builder: (context) {
            switch (store.state) {
              case 0:
                return Icon(FluentIcons.heart);
              case 1:
                return Icon(FluentIcons.heart_fill);
              default:
                return Icon(
                  FluentIcons.heart_fill,
                  color: Colors.red,
                );
            }
          }),
          text: Text(I18n.of(context).bookmark),
          onPressed: () async {
            await _onStar();
          },
        ),
        if (ClipboardPlugin.supported)
          MenuFlyoutItem(
            leading: Icon(FluentIcons.copy),
            text: Text(I18n.of(context).copy),
            onPressed: () async {
              final url = ClipboardPlugin.getImageUrl(store.illusts!, 0);
              if (url == null) return;

              ClipboardPlugin.showToast(
                context,
                ClipboardPlugin.copyImageFromUrl(url),
              );
            },
          ),
        MenuFlyoutItem(
          leading: Icon(FluentIcons.save),
          text: Text(I18n.of(context).save),
          onPressed: () async {
            await _onSave();
          },
        ),
        MenuFlyoutItem(
          leading: Icon(FluentIcons.favorite_list),
          text: Text(I18n.of(context).favorited_tag),
          onPressed: () async {
            final result = await showDialog<dynamic>(
              context: context,
              builder: (context) => TagForIllustPage(id: store.illusts!.id),
            );
            if (result?.isNotEmpty ?? false) {
              LPrinter.d(result);
              String restrict = result['restrict'];
              List<String>? tags = result['tags'];
              store.star(restrict: restrict, tags: tags, force: true);
            }
          },
        ),
      ],
    );
  }

  Widget _build(BuildContext context) {
    if (userSetting.hIsNotAllow) {
      final iR18 =
          store.illusts?.tags.indexWhere((I) => I.name.startsWith('R-18'));
      if (iR18 != null && iR18 != -1) {
        return PixEzButton(
          onPressed: () => _buildTap(context),
          child: Image.asset(Constants.no_h),
        );
      }
    }

    return buildInkWell(context);
  }

  _onSave() async {
    if (userSetting.longPressSaveConfirm) {
      final result = await showDialog<Bool>(
          context: context,
          builder: (context) {
            return ContentDialog(
              title: Text(I18n.of(context).save),
              content: Text(store.illusts?.title ?? ""),
              actions: <Widget>[
                HyperlinkButton(
                  child: Text(I18n.of(context).cancel),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                HyperlinkButton(
                  child: Text(I18n.of(context).ok),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            );
          });
      if (result != true) {
        return;
      }
    }
    saveStore.saveImage(store.illusts!);
  }

  Future _buildTap(BuildContext context) {
    return Leader.push(
      context,
      PictureListPage(
        iStores: iStores!,
        store: store,
        lightingStore: _lightingStore,
        heroString: tag,
      ),
      icon: const Icon(FluentIcons.picture),
      title: Text(I18n.of(context).illust_id + ': ${store.id}'),
    );
  }

  Widget cardText() {
    if (store.illusts!.type != "illust") {
      return Text(
        store.illusts!.type,
        style: TextStyle(color: Colors.white),
      );
    }
    if (store.illusts!.metaPages.isNotEmpty) {
      return Text(
        store.illusts!.metaPages.length.toString(),
        style: TextStyle(color: Colors.white),
      );
    }
    return Text('');
  }

  Widget _buildPic(String tag, bool tooLong) {
    return tooLong
        ? NullHero(
            tag: tag,
            child: PixivImage(store.illusts!.imageUrls.squareMedium,
                fit: BoxFit.fitWidth),
          )
        : NullHero(
            tag: tag,
            child: PixivImage(store.illusts!.imageUrls.medium,
                fit: BoxFit.fitWidth),
          );
  }

  Widget buildInkWell(BuildContext context) {
    var tooLong =
        store.illusts!.height.toDouble() / store.illusts!.width.toDouble() > 3;
    var radio = (tooLong)
        ? 1.0
        : store.illusts!.width.toDouble() / store.illusts!.height.toDouble();
    return _buildAnimationWraper(
        context,
        Column(
          children: <Widget>[
            AspectRatio(
                aspectRatio: radio,
                child: Stack(
                  children: [
                    Positioned.fill(child: _buildPic(tag, tooLong)),
                    Positioned(top: 5.0, right: 5.0, child: _buildVisibility()),
                  ],
                )),
            _buildBottom(context),
          ],
        ));
  }

  Widget _buildAnimationWraper(BuildContext context, Widget child) {
    return PixEzButton(
      child: child,
      onPressed: () {
        _buildInkTap(context, tag);
      },
    );
  }

  Future _buildInkTap(BuildContext context, String heroTag) {
    Widget widget;
    if (iStores != null) {
      widget = PictureListPage(
        heroString: heroTag,
        store: store,
        lightingStore: _lightingStore,
        iStores: iStores!,
      );
    } else {
      widget = IllustLightingPage(
        id: store.illusts!.id,
        heroString: heroTag,
        store: store,
      );
    }
    return Leader.push(
      context,
      widget,
      icon: Icon(FluentIcons.picture),
      title: Text(I18n.of(context).illust_id + ': ${store.illusts!.id}'),
    );
  }

  _onStar() async {
    store.star(restrict: userSetting.defaultPrivateLike ? "private" : "public");
    if (!userSetting.followAfterStar) {
      return;
    }
    bool success = await store.followAfterStar();
    if (success) {
      BotToast.showText(
          text: "${store.illusts!.user.name} ${I18n.of(context).followed}");
    }
  }

  Widget _buildBottom(BuildContext context) {
    return Container(
      color: FluentTheme.of(context).cardColor,
      child: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(
                left: 8.0, right: 36.0, top: 4, bottom: 4),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                store.illusts!.title,
                maxLines: 1,
                overflow: TextOverflow.clip,
                style: FluentTheme.of(context).typography.bodyStrong,
                strutStyle: StrutStyle(forceStrutHeight: true, leading: 0),
              ),
              Text(
                store.illusts!.user.name,
                maxLines: 1,
                overflow: TextOverflow.clip,
                style: FluentTheme.of(context).typography.body,
                strutStyle: StrutStyle(forceStrutHeight: true, leading: 0),
              )
            ]),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              child: Observer(builder: (_) {
                return StarIcon(
                  state: store.state,
                );
              }),
              onTap: _onStar,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildVisibility() {
    return Visibility(
      visible: store.illusts!.type != "illust" ||
          store.illusts!.metaPages.isNotEmpty,
      child: Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: EdgeInsets.all(4.0),
          child: Container(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 2.0, horizontal: 2.0),
              child: cardText(),
            ),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.all(Radius.circular(4.0)),
            ),
          ),
        ),
      ),
    );
  }
}
