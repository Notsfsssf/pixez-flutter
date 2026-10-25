import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:pixez/clipboard_plugin.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/illust.dart';
import 'package:pixez/page/picture/illust_store.dart';
import 'package:pixez/translation/translation_service.dart';
import 'package:pixez/translation/translation_store.dart';
import 'package:pixez/translation/widgets/translation_overlay.dart';
import 'package:pixez/utils/haptic_util.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path/path.dart';

class PhotoZoomPage extends StatefulWidget {
  final int index;
  final Illusts illusts;
  final IllustStore illustStore;

  const PhotoZoomPage({
    Key? key,
    required this.index,
    required this.illusts,
    required this.illustStore,
  }) : super(key: key);

  @override
  _PhotoZoomPageState createState() => _PhotoZoomPageState();
}

class _PhotoZoomPageState extends State<PhotoZoomPage> {
  late Illusts _illusts;
  int _index = 0;

  /// 每页独立的图片翻译状态（规格 §8.1）。
  final Map<int, ImageTranslationStore> _translationStores = {};

  bool get _translationAvailable => widget.illusts.type != 'ugoira';

  ImageTranslationStore _storeFor(int index) =>
      _translationStores.putIfAbsent(index, () {
        final store = ImageTranslationStore();
        // 解码回填真实尺寸后重建页面：PhotoView 的 childSize 与覆盖层
        // 必须同一时刻切到真实像素，否则译文块整体偏移（元数据尺寸与
        // 实际图片不一致时尤为明显）。
        store.onLayoutChanged = () {
          if (mounted) setState(() {});
        };
        return store;
      });

  /// 原图像素尺寸：优先用解码回填的真实尺寸，缺省退回 illusts 元数据。
  Size _originalSizeFor(int index) {
    final store = _translationStores[index];
    final width = store?.originalWidth.value ?? 0;
    final height = store?.originalHeight.value ?? 0;
    if (width > 0 && height > 0) return Size(width.toDouble(), height.toDouble());
    return Size(
      widget.illusts.width.toDouble(),
      widget.illusts.height.toDouble(),
    );
  }

  Widget _translatedChild(BuildContext context, int index, String url) {
    final store = _storeFor(index);
    // 尺寸必须在 Observer 外取一次：它要与 PhotoView 的 childSize 保持
    // 同一时刻的值，否则覆盖层和底图会各用一套尺寸、译文位置整体偏移。
    final size = _originalSizeFor(index);
    return Observer(
      builder: (context) {
        // 必须在这里（Observer 的 builder 内）真正遍历一次 ObservableList：
        // mobx 只在 builder 同步执行期间收集依赖，把 list 的引用传给子
        // widget、由子 widget 自己遍历是「读」不到的。真机表现就是翻译
        // 跑完、底部进度在动，图上一个译文块都不出现。
        final blocks = store.blocks.toList(growable: false);
        return TranslationOverlay(
          image: Image(
            image: PixivProvider.url(url),
            fit: BoxFit.fill,
            filterQuality: FilterQuality.high,
          ),
          originalSize: size,
          blocks: blocks,
          showAllOriginal: store.showAllOriginal.value,
          showsOriginalAt: store.showsOriginal,
          onBlockTap: store.toggleBlockOriginal,
          onBlockLongPress: store.toggleBlockOriginal,
        );
      },
    );
  }

  /// [context] 显式传入：异步流程结束后不再依赖 State.context 取值。
  Future<void> _startTranslation(
    int index,
    String url,
    BuildContext context,
  ) async {
    final store = _storeFor(index);
    if (store.isWorking) return;
    final service = TranslationService.instance;
    await service.ensureInitialized();
    final size = _originalSizeFor(index);
    await store.translateImage(
      url: url,
      originalWidth: size.width.round(),
      originalHeight: size.height.round(),
      pipeline: service,
    );
    if (store.noTextFound.value && mounted) {
      BotToast.showText(text: I18n.of(context).translation_no_text_found);
    } else if (store.state == TranslatedImageState.error && mounted) {
      // 拼上具体错误（含 LLM/OCR 失败原因），不然只有「翻译失败」四个字没法排障。
      final detail = store.error ?? '';
      BotToast.showText(
        text: detail.isEmpty
            ? I18n.of(context).translation_failed
            : '${I18n.of(context).translation_failed}\n$detail',
      );
    }
  }

  @override
  void initState() {
    _loadSource = userSetting.zoomQuality == 1;
    _illusts = widget.illusts;
    _index = widget.index;
    nowUrl = _illusts.pageCount == 1
        ? (_loadSource
              ? _illusts.metaSinglePage!.originalImageUrl!
              : _illusts.imageUrls.large)
        : (_loadSource
              ? _illusts.metaPages[_index].imageUrls!.original
              : _illusts.metaPages[_index].imageUrls!.large);

    super.initState();
    initCache();
  }

  @override
  void dispose() {
    if (_fullScreen)
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: SystemUiOverlay.values,
      );
    super.dispose();
  }

  initCache() async {
    var fileInfo = await pixivCacheManager!.getFileFromCache(
      nowUrl,
    );
    if (mounted)
      setState(() {
        shareShow = fileInfo != null;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        if (_illusts.pageCount == 1) {
          final url = _loadSource
              ? _illusts.metaSinglePage!.originalImageUrl!
              : _illusts.imageUrls.large;
          return Scaffold(
            extendBody: true,
            extendBodyBehindAppBar: true,
            backgroundColor: Colors.black,
            bottomNavigationBar: _buildBottom(context),
            body: Container(
              child: PhotoView.customChild(
                // customChild 模式必须用 none：非 none 会进入 photo_view 的
                // 「Image 自行缩放」路径，而 customChild 没有执行者（Transform
                // scale 恒 1、child 无约束），整页以原始像素渲染——打开即放大。
                // 图像采样质量由 TranslationOverlay 内 Image 的 filterQuality 保证。
                filterQuality: FilterQuality.none,
                initialScale: PhotoViewComputedScale.contained,
                heroAttributes: PhotoViewHeroAttributes(tag: url),
                childSize: _originalSizeFor(0),
                child: _translatedChild(context, 0, url),
              ),
            ),
          );
        } else {
          return Scaffold(
            extendBody: true,
            bottomNavigationBar: _buildBottom(context),
            extendBodyBehindAppBar: true,
            backgroundColor: Colors.black,
            body: ScrollConfiguration(
              // Flutter excludes mouse from dragDevices by default (#1308).
              behavior: ScrollConfiguration.of(context).copyWith(
                dragDevices: {
                  PointerDeviceKind.touch,
                  PointerDeviceKind.stylus,
                  PointerDeviceKind.invertedStylus,
                  PointerDeviceKind.trackpad,
                  PointerDeviceKind.mouse,
                },
              ),
              child: PhotoViewGallery.builder(
                scrollPhysics: const BouncingScrollPhysics(),
                pageController: PageController(initialPage: _index),
                builder: (BuildContext context, int index) {
                  final url = _loadSource
                      ? _illusts.metaPages[index].imageUrls!.original
                      : _illusts.metaPages[index].imageUrls!.large;
                  return PhotoViewGalleryPageOptions.customChild(
                    childSize: _originalSizeFor(index),
                    initialScale: PhotoViewComputedScale.contained,
                    heroAttributes: PhotoViewHeroAttributes(tag: url),
                    // 同上：customChild 模式下非 none 会让缩放失效（打开即放大）。
                    filterQuality: FilterQuality.none,
                    child: _translatedChild(context, index, url),
                  );
                },
                itemCount: _illusts.metaPages.length,
                onPageChanged: (index) async {
                  nowUrl = _loadSource
                      ? _illusts.metaPages[index].imageUrls!.original
                      : _illusts.metaPages[index].imageUrls!.large;
                  setState(() {
                    _index = index;
                    shareShow = false;
                  });
                  var file = await pixivCacheManager!.getFileFromCache(
                    nowUrl,
                  );
                  if (file != null && mounted)
                    setState(() {
                      shareShow = true;
                    });
                },
                loadingBuilder: (context, event) => _buildLoading(event),
              ),
            ),
          );
        }
      },
    );
  }

  String nowUrl = "";

  bool show = false;
  bool shareShow = false;
  bool _loadSource = false;
  bool _fullScreen = false;

  Widget _buildBottom(BuildContext context) {
    if (_fullScreen) {
      return BottomAppBar(
        color: Colors.transparent,
        child: Row(
          children: [
            IconButton(
              onPressed: () {
                setState(() {
                  _fullScreen = false;
                });
                SystemChrome.setEnabledSystemUIMode(
                  SystemUiMode.manual,
                  overlays: SystemUiOverlay.values,
                );
              },
              icon: Icon(
                Icons.fullscreen_exit,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      );
    }
    return BottomAppBar(
      color: Colors.transparent,
      child: Visibility(
        visible: true,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                IconButton(
                  iconSize: 16,
                  icon: Icon(Icons.photo_library_outlined, color: Colors.white),
                  onPressed: () {},
                ),
                Text(
                  "${_index + 1}/${widget.illusts.pageCount}",
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge!.copyWith(color: Colors.white),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (_translationAvailable)
                  Observer(builder: (context) {
                    final store = _storeFor(_index);
                    return IconButton(
                      tooltip: I18n.of(context).translation,
                      icon: store.isWorking
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                ),
                                // 批量推理是「一批完成才上屏」，没有数字时
                                // 界面看起来像卡死：这里直接暴露已翻译段数。
                                if (store.totalCount > 0) ...[
                                  const SizedBox(width: 3),
                                  Text(
                                    '${store.translatedCount}/${store.totalCount}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ],
                            )
                          : Icon(
                              Icons.translate,
                              color: store.state == TranslatedImageState.done
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.white,
                            ),
                      onPressed: () async {
                        final url = _illusts.pageCount == 1
                            ? nowUrl
                            : (_loadSource
                                ? _illusts.metaPages[_index]
                                    .imageUrls!.original
                                : _illusts.metaPages[_index].imageUrls!.large);
                        await _startTranslation(_index, url, context);
                      },
                    );
                  }),
                Observer(builder: (context) {
                  final store = _storeFor(_index);
                  if (!_translationAvailable ||
                      store.state != TranslatedImageState.done ||
                      store.blocks.isEmpty) {
                    return SizedBox.shrink();
                  }
                  return IconButton(
                    tooltip: store.showAllOriginal.value
                        ? I18n.of(context).translation_show_translation
                        : I18n.of(context).translation_show_source,
                    icon: Icon(
                      store.showAllOriginal.value
                          ? Icons.image_outlined
                          : Icons.g_translate,
                      color: Colors.white,
                    ),
                    onPressed: store.toggleAllOriginal,
                  );
                }),
                IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () async {
                    Navigator.of(context).pop();
                  },
                ),
                IconButton(
                  icon: Icon(Icons.fullscreen, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      _fullScreen = true;
                    });
                    SystemChrome.setEnabledSystemUIMode(
                      SystemUiMode.manual,
                      overlays: [],
                    );
                  },
                ),
                if (ClipboardPlugin.supported)
                  IconButton(
                    icon: Icon(Icons.copy, color: Colors.white),
                    onPressed: () =>
                        ClipboardPlugin.copy(context, _illusts, _index),
                  ),
                GestureDetector(
                  child: IconButton(
                    icon: Icon(Icons.save_alt, color: Colors.white),
                    onPressed: () {
                      if (_illusts.metaPages.isNotEmpty)
                        saveStore.saveImage(widget.illusts, index: _index);
                      else
                        saveStore.saveImage(widget.illusts);
                      if (userSetting.starAfterSave &&
                          (widget.illustStore.state == 0)) {
                        widget.illustStore.star(
                          restrict: userSetting.defaultPrivateLike
                              ? "private"
                              : "public",
                        );
                      }
                    },
                  ),
                  onLongPress: () async {
                    HapticUtil.heavy();
                    if (_illusts.metaPages.isNotEmpty)
                      saveStore.saveImage(widget.illusts, index: _index);
                    else
                      saveStore.saveImage(widget.illusts);
                  },
                ),
                AnimatedOpacity(
                  opacity: shareShow ? 1 : 0.5,
                  duration: Duration(milliseconds: 500),
                  child: Builder(
                    builder: (context) {
                      return IconButton(
                        icon: Icon(Icons.share, color: Colors.white),
                        onPressed: () async {
                          var file = await pixivCacheManager!.getFileFromCache(
                            nowUrl,
                          );
                          if (file != null) {
                            String targetPath = join(
                              (await getTemporaryDirectory()).path,
                              "share_cache",
                              basenameWithoutExtension(file.file.path) +
                                  (nowUrl.endsWith(".png") ? ".png" : ".jpg"),
                            );
                            File targetFile = new File(targetPath);
                            if (!targetFile.existsSync()) {
                              targetFile.createSync(recursive: true);
                            }
                            file.file.copySync(targetPath);
                            final box =
                                context.findRenderObject() as RenderBox?;
                            SharePlus.instance.share(
                              ShareParams(
                                files: [XFile(targetPath)],
                                sharePositionOrigin:
                                    box!.localToGlobal(Offset.zero) & box.size,
                              ),
                            );
                          } else {
                            BotToast.showText(text: "can not find image cache");
                          }
                        },
                      );
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(
                    !_loadSource ? Icons.hd_outlined : Icons.hd,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      _loadSource = !_loadSource;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Center _buildLoading(ImageChunkEvent? event) {
    double value = event == null || event.expectedTotalBytes == null
        ? 0
        : event.cumulativeBytesLoaded / event.expectedTotalBytes!;
    if (value == 1.0) {
      Future.delayed(Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            shareShow = true;
          });
        }
      });
    }
    return Center(
      child: Container(
        width: 20.0,
        height: 20.0,
        child: CircularProgressIndicator(value: value),
      ),
    );
  }
}
