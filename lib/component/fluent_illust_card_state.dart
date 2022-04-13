import 'package:bot_toast/bot_toast.dart';
import 'package:contextmenu/contextmenu.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/component/illust_card.dart';
import 'package:pixez/component/null_hero.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/component/star_icon.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/page/picture/illust_lighting_page.dart';
import 'package:pixez/page/picture/illust_store.dart';
import 'package:pixez/page/picture/picture_list_page.dart';
import 'package:pixez/page/picture/tag_for_illust_page.dart';

class FluentIllustCardState extends IllustCardStateBase {
  late IllustStore store;
  late List<IllustStore>? iStores;
  late String tag;

  @override
  void initState() {
    store = widget.store;
    iStores = widget.iStores;
    tag = this.hashCode.toString();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant IllustCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    store = widget.store;
    iStores = widget.iStores;
  }

  @override
  Widget build(BuildContext context) {
    if (userSetting.hIsNotAllow)
      for (int i = 0; i < store.illusts!.tags.length; i++) {
        if (store.illusts!.tags[i].name.startsWith('R-18'))
          return HoverButton(
              onPressed: () => _buildTap(context),
              onLongPress: () => saveStore.saveImage(store.illusts!),
              builder: (context, state) {
                return FocusBorder(
                    focused: state.isFocused || state.isHovering,
                    child: Card(
                      // margin: EdgeInsets.all(8.0),
                      elevation: 8.0,
                      // clipBehavior: Clip.antiAlias,
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      child: Image.asset('assets/images/h.jpg'),
                    ));
              });
      }
    return buildInkWell(context);
  }

  _buildTap(BuildContext context) {
    if (store != null)
      Leader.dialog(
        context,
        PictureListPage(
          iStores: iStores!,
          store: store,
          heroString: tag,
        ),
      );
    else
      Leader.dialog(
        context,
        IllustLightingPage(
          store: store,
          id: store.illusts!.id,
          heroString: tag,
        ),
      );
    // return Navigator.of(context, rootNavigator: true)
    //     .push(FluentPageRoute(builder: (_) {
    //   if (store != null) {
    //     return PictureListPage(
    //       iStores: iStores!,
    //       store: store,
    //       heroString: tag,
    //     );
    //   }
    //   return IllustLightingPage(
    //     store: store,
    //     id: store.illusts!.id,
    //     heroString: tag,
    //   );
    // }));
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
    return ContextMenuArea(
      width: 120,
      builder: (context) {
        return [
          TappableListTile(
            title: Text("Star"),
            onTap: () async {
              store.star();
              if (!userSetting.followAfterStar) {
                return;
              }
              bool success = await store.followAfterStar();
              if (success) {
                BotToast.showText(
                    text:
                        "${store.illusts!.user.name} ${I18n.of(context).followed}");
              }
            },
          ),
          TappableListTile(
            title: Text("Save"),
            onTap: () {
              saveStore.saveImage(store.illusts!);
            },
          ),
        ];
      },
      child: HoverButton(
        margin: EdgeInsets.all(8.0),
        onLongPress: () {
          saveStore.saveImage(store.illusts!);
        },
        onPressed: () {
          _buildInkTap(context, tag);
        },
        builder: (context, state) {
          return FocusBorder(
            focused: state.isFocused || state.isHovering,
            child: Acrylic(
              child: Column(
                children: <Widget>[
                  AspectRatio(
                    aspectRatio: radio,
                    child: Stack(
                      children: [
                        Positioned.fill(child: _buildPic(tag, tooLong)),
                        Positioned(
                            top: 5.0, right: 5.0, child: _buildVisibility()),
                      ],
                    ),
                  ),
                  _buildBottom(context),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  _buildInkTap(BuildContext context, String heroTag) {
    if (iStores != null)
      Leader.dialog(
        context,
        PictureListPage(
          iStores: iStores!,
          store: store,
          heroString: heroTag,
        ),
      );
    else
      Leader.dialog(
        context,
        IllustLightingPage(
          store: store,
          id: store.illusts!.id,
          heroString: heroTag,
        ),
      );
    // return Navigator.of(context, rootNavigator: true)
    //     .push(FluentPageRoute(builder: (_) {
    //   if (iStores != null) {
    //     return PictureListPage(
    //       heroString: heroTag,
    //       store: store,
    //       iStores: iStores!,
    //     );
    //   }
    //   return IllustLightingPage(
    //     id: store.illusts!.id,
    //     heroString: heroTag,
    //     store: store,
    //   );
    // }));
  }

  Widget _buildBottom(BuildContext context) {
    return Container(
      color: Colors.transparent, //FluentTheme.of(context).cardColor,
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
                style: FluentTheme.of(context).typography.body,
              ),
              Text(
                store.illusts!.user.name,
                maxLines: 1,
                overflow: TextOverflow.clip,
                style: FluentTheme.of(context).typography.caption,
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
              onTap: () async {
                store.star();
                if (!userSetting.followAfterStar) {
                  return;
                }
                bool success = await store.followAfterStar();
                if (success) {
                  BotToast.showText(
                      text:
                          "${store.illusts!.user.name} ${I18n.of(context).followed}");
                }
              },
              // TODO
              // onLongPress: () async {
              //   final result = await showModalBottomSheet(
              //     context: context,
              //     clipBehavior: Clip.hardEdge,
              //     shape: RoundedRectangleBorder(
              //       borderRadius:
              //           BorderRadius.vertical(top: Radius.circular(16)),
              //     ),
              //     constraints: BoxConstraints.expand(
              //         height: MediaQuery.of(context).size.height * .618),
              //     isScrollControlled: true,
              //     builder: (_) => TagForIllustPage(id: store.illusts!.id),
              //   );
              //   if (result?.isNotEmpty ?? false) {
              //     LPrinter.d(result);
              //     String restrict = result['restrict'];
              //     List<String>? tags = result['tags'];
              //     store.star(restrict: restrict, tags: tags, force: true);
              //   }
              // },
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
