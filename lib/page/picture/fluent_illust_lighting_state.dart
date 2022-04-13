import 'package:contextmenu/contextmenu.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/component/null_hero.dart';
import 'package:pixez/component/painter_avatar.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/component/selectable_html.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/er/lprinter.dart';
import 'package:pixez/exts.dart';
import 'package:pixez/component/fluent_ink_well.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/ban_tag.dart';
import 'package:pixez/models/illust.dart';
import 'package:pixez/page/comment/comment_page.dart';
import 'package:pixez/page/picture/illust_about_store.dart';
import 'package:pixez/page/picture/illust_lighting_page.dart';
import 'package:pixez/page/picture/illust_store.dart';
import 'package:pixez/page/picture/ugoira_loader.dart';
import 'package:pixez/page/search/result_page.dart';
import 'package:pixez/page/user/user_store.dart';
import 'package:pixez/page/user/users_page.dart';
import 'package:pixez/page/zoom/photo_zoom_page.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class FluentIllustLightingPageState extends IllustLightingPageStateBase {
  UserStore? userStore;
  late IllustStore _illustStore;
  late IllustAboutStore _aboutStore;
  late ScrollController _scrollController;
  late RefreshController _refreshController;
  bool tempView = false;
  bool _commentVisiblity = false;

  @override
  bool get wantKeepAlive => false;

  @override
  void initState() {
    _refreshController = RefreshController();
    _scrollController = ScrollController();
    _illustStore = widget.store ?? IllustStore(widget.id, null);
    _illustStore.fetch();
    _aboutStore =
        IllustAboutStore(widget.id, refreshController: _refreshController);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant IllustLightingPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.store != widget.store) {
      _illustStore = widget.store ?? IllustStore(widget.id, null);
      _illustStore.fetch();
      _aboutStore = IllustAboutStore(widget.id);
      LPrinter.d("state change");
    }
  }

  @override
  void dispose() {
    _illustStore.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ScaffoldPage(
      header: _buildHeader(),
      content: _buildContent(),
    );
  }

  PageHeader _buildHeader() {
    return PageHeader(
      title: Text(_illustStore.illusts?.title ?? "<Error>"),
      commandBar: CommandBar(
        overflowBehavior: CommandBarOverflowBehavior.noWrap,
        primaryItems: [
          CommandBarButton(
            icon: Icon(FluentIcons.refresh),
            label: Text(I18n.of(context).refresh),
            onPressed: () {
              _illustStore.fetch();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final data = _illustStore.illusts!;

    return Row(children: [
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: LimitedBox(
          maxWidth: 400,
          child: _buildImageView(data),
        ),
      ),
      Expanded(
        child: ListView(
          // crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInfoPane(context, data),
            _buildTagPane(data),
            _buildCaptionPane(data),
            _buildCommentPane(data),
          ],
        ),
      ),
      Expanded(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(I18n.of(context).about_picture),
          ),
          _buildAboutPicturePane(),
        ]),
      )
    ]);
  }

  Widget _buildImageView(Illusts data) {
    print("Illust Type is ${data.type}");
    print("Illust Count is ${data.pageCount}");
    if (data.type == "ugoira") {
      return NullHero(
        tag: widget.heroString,
        child: UgoiraLoader(
          id: widget.id,
          illusts: data,
        ),
      );
    } else {
      return _buildIllustView(data);
    }
  }

  Widget _buildIllustView(Illusts data) {
    final width = data != null
        ? ((data.width.toDouble() / data.height) *
            MediaQuery.of(context).size.height)
        : 150.0;

    if (data.metaPages.isEmpty) {
      String url = userSetting.pictureQuality == 1
          ? data.imageUrls.large
          : data.imageUrls.medium;
      if (data.type == "manga") {
        if (userSetting.mangaQuality == 0)
          url = data.imageUrls.medium;
        else if (userSetting.mangaQuality == 1)
          url = data.imageUrls.large;
        else
          url = data.metaSinglePage!.originalImageUrl!;
      }
      final placeWidget = Container(width: width);
      return InkWell(
        onLongPress: () {
          pressSave(data, 0);
        },
        onTap: () {
          Leader.push(
              context,
              PhotoZoomPage(
                index: 0,
                illusts: data,
              ));
        },
        child: NullHero(
          tag: widget.heroString,
          child: PixivImage(
            url,
            fade: false,
            width: MediaQuery.of(context).size.width,
            placeWidget: (url != data.imageUrls.medium)
                ? PixivImage(
                    data.imageUrls.medium,
                    width: MediaQuery.of(context).size.width,
                    placeWidget: placeWidget,
                    fade: false,
                  )
                : placeWidget,
          ),
        ),
      );
    } else {
      final children = List<Widget>.of([]);
      for (var i = 0; i < data.metaPages.length; i++) {
        children.add(
          InkWell(
            margin: EdgeInsets.all(4.0),
            onLongPress: () {
              pressSave(data, i);
            },
            onTap: () {
              Leader.fluentNav(
                  context,
                  Icon(FluentIcons.image_pixel),
                  Text("图片预览 ${data.id}"),
                  PhotoZoomPage(
                    index: i,
                    illusts: data,
                  ));
            },
            child: _buildIllustsItem(i, data, width),
          ),
        );
      }
      return ListView(
        children: children,
      );
    }
  }

  Widget _buildIllustsItem(int index, Illusts illust, double width) {
    if (illust.type == "manga") {
      String url;
      if (userSetting.mangaQuality == 0)
        url = illust.metaPages[index].imageUrls!.medium;
      else if (userSetting.mangaQuality == 1)
        url = illust.metaPages[index].imageUrls!.large;
      else
        url = illust.metaPages[index].imageUrls!.original;
      if (index == 0)
        return NullHero(
          child: PixivImage(
            url,
            placeWidget: PixivImage(
              illust.metaPages[index].imageUrls!.medium,
              height: MediaQuery.of(context).size.height,
              fade: false,
            ),
            height: MediaQuery.of(context).size.height,
            fade: false,
          ),
          tag: widget.heroString,
        );
      return PixivImage(
        url,
        fade: false,
        height: MediaQuery.of(context).size.height,
        placeWidget: Container(
          width: width,
          child: Center(
            child: Text('$index',
                style: FluentTheme.of(context).typography.caption),
          ),
        ),
      );
    }
    return index == 0
        ? (userSetting.pictureQuality == 1
            ? NullHero(
                child: PixivImage(
                  illust.metaPages[index].imageUrls!.large,
                  placeWidget: PixivImage(
                    illust.metaPages[index].imageUrls!.medium,
                    fade: false,
                  ),
                  fade: false,
                ),
                tag: widget.heroString,
              )
            : NullHero(
                child: PixivImage(
                  illust.metaPages[index].imageUrls!.medium,
                  fade: false,
                ),
                tag: widget.heroString,
              ))
        : PixivImage(
            userSetting.pictureQuality == 0
                ? illust.metaPages[index].imageUrls!.medium
                : illust.metaPages[index].imageUrls!.large,
            fade: false,
            placeWidget: Container(
              height: 150,
              child: Center(
                child: Text('$index',
                    style: FluentTheme.of(context).typography.caption),
              ),
            ),
          );
  }

  Widget _buildInfoPane(BuildContext context, Illusts data) {
    return InkWell(
      isHoverable: false,
      margin: EdgeInsets.fromLTRB(0, 0, 0, 1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          _buildNameAvatar(context, data),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text(I18n.of(context).illust_id),
              Container(
                width: 10.0,
              ),
              colorText(data.id.toString(), context),
              Container(
                width: 20.0,
              ),
              Text(I18n.of(context).pixel),
              Container(
                width: 10.0,
              ),
              colorText("${data.width}x${data.height}", context)
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text(I18n.of(context).total_view),
              Container(
                width: 10.0,
              ),
              colorText(data.totalView.toString(), context),
              Container(
                width: 20.0,
              ),
              Text(I18n.of(context).total_bookmark),
              Container(
                width: 10.0,
              ),
              colorText("${data.totalBookmarks}", context)
            ],
          ),
        ],
      ),
      mode: InkWellMode.cardOnly,
    );
  }

  Widget _buildTagPane(Illusts data) {
    return InkWell(
      isHoverable: false,
      margin: EdgeInsets.fromLTRB(0, 0, 0, 1),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 2,
          runSpacing: 0,
          children: [for (var f in data.tags) buildRow(context, f)],
        ),
      ),
      mode: InkWellMode.cardOnly,
    );
  }

  Widget _buildNameAvatar(BuildContext context, Illusts illust) {
    if (userStore == null)
      userStore = UserStore(illust.user.id, user: illust.user);
    return Observer(builder: (_) {
      Future.delayed(Duration(seconds: 2), () {
        _loadAbout();
      });
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
              child: InkWell(
                mode: InkWellMode.focusBorderOnly,
                onLongPress: () {
                  userStore!.follow();
                },
                child: Container(
                  height: 70,
                  width: 70,
                  child: Stack(
                    children: <Widget>[
                      Center(
                        child: SizedBox(
                          height: 70,
                          width: 70,
                          child: Container(
                            decoration: illust != null
                                ? BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: userStore!.isFollow
                                        ? Colors.yellow
                                        : FluentTheme.of(context).accentColor,
                                  )
                                : BoxDecoration(),
                          ),
                        ),
                      ),
                      Center(
                        child: Hero(
                          tag: illust.user.profileImageUrls.medium +
                              this.hashCode.toString(),
                          child: PainterAvatar(
                            url: illust.user.profileImageUrls.medium,
                            id: illust.user.id,
                            onTap: () async {
                              await Leader.push(
                                  context,
                                  UsersPage(
                                    id: illust.user.id,
                                    userStore: userStore,
                                    heroTag: this.hashCode.toString(),
                                  ));
                              _illustStore.illusts!.user.isFollowed =
                                  userStore!.isFollow;
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              padding: EdgeInsets.all(8.0)),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SelectableText(
                    illust.title,
                    style:
                        TextStyle(color: FluentTheme.of(context).accentColor),
                  ),
                  Container(
                    height: 4.0,
                  ),
                  Hero(
                    tag: illust.user.name + this.hashCode.toString(),
                    child: SelectableText(
                      illust.user.name,
                      style: FluentTheme.of(context).typography.bodyLarge,
                    ),
                  ),
                  Text(
                    illust.createDate.toShortTime(),
                    style: FluentTheme.of(context).typography.caption,
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildCaptionPane(Illusts data) {
    return SelectableHtml(
      data: data.caption.isEmpty ? "~" : data.caption,
    );
  }

  Widget _buildCommentPane(Illusts data) {
    return Expander(
      header: Text(
        I18n.of(context).view_comment,
        textAlign: TextAlign.center,
      ),
      content: _commentVisiblity
          ? LimitedBox(
              maxHeight: 400,
              child: SafeArea(child: CommentPage(id: data.id)),
            )
          : const Text("Hide"),
      onStateChanged: (state) {
        SchedulerBinding.instance?.addPostFrameCallback((timeStamp) {
          setState(() {
            _commentVisiblity = state;
          });
        });
      },
    );
  }

  Widget _buildAboutPicturePane() {
    return Text("TODO");
    // final list = _aboutStore.illusts
    //     .map((element) => IllustStore(element.id, element))
    //     .toList();
    // return GridView.builder(
    //   gridDelegate:
    //       SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
    //   itemBuilder: (context, index) {
    //     return HoverButton(
    //       onPressed: () {
    //         Leader.push(
    //             context,
    //             PictureListPage(
    //               iStores: list,
    //               store: list[index],
    //             ));
    //       },
    //       onLongPress: () {
    //         saveStore.saveImage(_aboutStore.illusts[index]);
    //       },
    //       builder: (context, state) {
    //         return FocusBorder(
    //           focused: state.isFocused || state.isHovering,
    //           child: PixivImage(
    //             _aboutStore.illusts[index].imageUrls.squareMedium,
    //             enableMemoryCache: false,
    //           ),
    //         );
    //       },
    //     );
    //   },
    //   itemCount: _aboutStore.illusts.length,
    // );
  }

  Widget colorText(String text, BuildContext context) => SelectableText(
        text,
        style: TextStyle(color: FluentTheme.of(context).accentColor),
      );

  Widget buildRow(BuildContext context, Tags f) {
    return InkWell(
      onLongPress: () async {
        await _longPressTag(context, f);
      },
      onTap: () {
        Leader.fluentNav(
            context,
            Icon(FluentIcons.search),
            Text("搜索 #${f.name}"),
            ResultPage(
              word: f.name,
              translatedName: f.translatedName ?? "",
            ));
      },
      child: ContextMenuArea(
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: "#${f.name}",
            children: [
              TextSpan(
                text: " ",
                style: FluentTheme.of(context).typography.caption,
              ),
              TextSpan(
                  text: "${f.translatedName ?? "~"}",
                  style: FluentTheme.of(context).typography.caption)
            ],
            style: FluentTheme.of(context)
                .typography
                .caption!
                .copyWith(color: FluentTheme.of(context).accentColor),
          ),
        ),
        width: 200,
        builder: (context) => [
          TappableListTile(
            onTap: () {
              muteStore.insertBanTag(
                BanTagPersist(
                    name: f.name, translateName: f.translatedName ?? ""),
              );
            },
            title: Text(I18n.of(context).ban),
            leading: Icon(FluentIcons.blocked),
          ),
          TappableListTile(
            onTap: () {
              bookTagStore.bookTag(f.name);
            },
            title: Text(I18n.of(context).bookmark),
            leading: Icon(FluentIcons.add_bookmark),
          ),
          TappableListTile(
            onTap: () async {
              await Clipboard.setData(ClipboardData(text: f.name));
              showSnackbar(
                  context,
                  Snackbar(
                    //duration: Duration(seconds: 1),
                    content: Text(I18n.of(context).copied_to_clipboard),
                  ));
            },
            title: Text(I18n.of(context).copy),
            leading: Icon(FluentIcons.copy),
          ),
        ],
      ),
      mode: InkWellMode.focusBorderOnly,
    );
  }

  Future _longPressTag(BuildContext context, Tags f) async {
    switch (await showDialog(
        context: context,
        builder: (BuildContext context) {
          return ContentDialog(
            title: Text(f.name),
            actions: [
              Button(
                onPressed: () {
                  Navigator.pop(context, 0);
                },
                child: Text(I18n.of(context).ban),
              ),
              Button(
                onPressed: () {
                  Navigator.pop(context, 1);
                },
                child: Text(I18n.of(context).bookmark),
              ),
              Button(
                onPressed: () {
                  Navigator.pop(context, 2);
                },
                child: Text(I18n.of(context).copy),
              ),
            ],
          );
        })) {
      case 0:
        {
          muteStore.insertBanTag(BanTagPersist(
              name: f.name, translateName: f.translatedName ?? ""));
        }
        break;
      case 1:
        {
          bookTagStore.bookTag(f.name);
        }
        break;
      case 2:
        {
          await Clipboard.setData(ClipboardData(text: f.name));
          showSnackbar(
              context,
              Snackbar(
                //duration: Duration(seconds: 1),
                content: Text(I18n.of(context).copied_to_clipboard),
              ));
        }
    }
  }

  void _loadAbout() {
    if (mounted &&
        _scrollController.hasClients &&
        _scrollController.offset + 180 >=
            _scrollController.position.maxScrollExtent &&
        _aboutStore.illusts.isEmpty) _aboutStore.fetch();
  }
}
