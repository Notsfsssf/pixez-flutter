import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:dio/dio.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pixez/component/illust_card.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/desktop/desktop_shell.dart';
import 'package:pixez/desktop/download_folder_tile.dart';
import 'package:pixez/document_plugin.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart' as app;
import 'package:pixez/network/api_client.dart';
import 'package:pixez/network/oauth_client.dart';
import 'package:pixez/page/picture/picture_list_page.dart';
import 'package:pixez/page/search/result_page.dart';
import 'package:pixez/page/search/suggest/search_suggestion_page.dart';
import 'package:window_manager/window_manager.dart';

import 'fixtures/desktop_artworks.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets('mouse download, native destination and desktop search navigation', (
    tester,
  ) async {
    // Stabilize API metadata only. Image downloads, files and the native save
    // channel remain real; no bookmark or follow endpoints are called.
    final feed = jsonDecode(desktopArtworkJson) as Map<String, dynamic>;
    apiClient.httpClient.interceptors.removeWhere((i) => i is LogInterceptor);
    oAuthClient.httpClient.interceptors.removeWhere((i) => i is LogInterceptor);
    apiClient.httpClient.interceptors.insert(
      0,
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final path = options.uri.path;
          dynamic data = <String, dynamic>{};
          if (path.contains('spotlight')) {
            data = {'spotlight_articles': [], 'next_url': null};
          } else if (path.contains('user/recommended')) {
            data = {'user_previews': [], 'next_url': null};
          } else if (path.contains('trending-tags')) {
            data = {'trend_tags': []};
          } else if (path.contains('autocomplete')) {
            data = {'search_auto_complete_keywords': []};
          } else if (path.contains('illust/detail')) {
            data = {
              'illust': (feed['illusts'] as List).firstWhere(
                (a) =>
                    '${a['id']}' == '${options.queryParameters['illust_id']}',
                orElse: () => feed['illusts'][0],
              ),
            };
          } else if (path.contains('illust/related')) {
            data = {'illusts': [], 'next_url': null};
          } else if (path.contains('recommended') ||
              path.contains('search/illust')) {
            data = feed;
          }
          handler.resolve(
            Response(requestOptions: options, data: data, statusCode: 200),
          );
        },
      ),
    );
    await app.main([]);
    await windowManager.show();
    await windowManager.focus();
    await windowManager.setSize(const Size(1280, 820));
    await windowManager.setAlwaysOnTop(true);
    addTearDown(() => windowManager.setAlwaysOnTop(false));

    Future<void> until(bool Function() ready) async {
      for (var i = 0; i < 150 && !ready(); i++) {
        await tester.pump(const Duration(milliseconds: 200));
      }
      expect(ready(), isTrue);
      await tester.pump(const Duration(milliseconds: 500));
    }

    Future<void> screenshot(String name) async {
      await tester.pump(const Duration(milliseconds: 400));
      await tester.runAsync(() async {
        final boundary = tester.renderObject<RenderRepaintBoundary>(
          find.byType(RepaintBoundary).first,
        );
        final image = await boundary.toImage(pixelRatio: 1);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        final directory = Directory(
          '${(await getTemporaryDirectory()).path}/desktop-ui-proof',
        );
        await directory.create(recursive: true);
        await File(
          '${directory.path}/$name.png',
        ).writeAsBytes(bytes!.buffer.asUint8List());
        image.dispose();
        print('MOUSE_SCREENSHOT: $name');
      });
    }

    Future<Offset> visiblePoint(Finder target) async {
      await tester.ensureVisible(target);
      await tester.pump(const Duration(milliseconds: 300));
      final pane = tester.getRect(find.byType(Navigator).last);
      final visible = tester
          .getRect(target)
          .intersect(
            Rect.fromLTRB(pane.left, pane.top + 110, pane.right, pane.bottom),
          );
      expect(visible.isEmpty, isFalse);
      return visible.center;
    }

    Future<void> secondaryClick(Finder target) async {
      await tester.tapAt(
        await visiblePoint(target),
        buttons: kSecondaryMouseButton,
        kind: PointerDeviceKind.mouse,
      );
      await tester.pump(const Duration(milliseconds: 400));
    }

    await until(
      () =>
          find.byType(DesktopShell).evaluate().isNotEmpty &&
          app.accountStore.now != null,
    );
    var shell = tester.widget<DesktopShell>(find.byType(DesktopShell));
    await tester.tap(find.text(shell.labels[0]).first);
    await until(() => find.byType(IllustCard).evaluate().isNotEmpty);
    IllustCard? selected;
    for (final card in tester.widgetList<IllustCard>(find.byType(IllustCard))) {
      final original = card.store.illusts!.metaSinglePage!.originalImageUrl!;
      if (await tester.runAsync(
            () => app.fetcher.taskPersistProvider.getAccount(original),
          ) ==
          null) {
        selected = card;
        break;
      }
    }
    expect(
      selected,
      isNotNull,
      reason: 'Need a sample not already in the download task history',
    );
    final artwork = selected!.store.illusts!;
    final card = find.byWidgetPredicate(
      (w) => w is IllustCard && w.store.id == artwork.id,
    );
    final labels = I18n.of(tester.element(find.byType(DesktopShell)));
    final settings = app.userSetting;
    final previous = (
      settings.format,
      settings.fileNameEval,
      settings.singleFolder,
      settings.overSanityLevelFolder,
    );
    settings.format = 'codex_mouse_check_{illust_id}_p{part}';
    settings.fileNameEval = 0;
    settings.singleFolder = false;
    settings.overSanityLevelFolder = false;
    try {
      await secondaryClick(card);
      final save = find.widgetWithText(PopupMenuItem<String>, labels.save);
      expect(save, findsOneWidget);
      await screenshot('artwork-right-click');
      await tester.tap(save, kind: PointerDeviceKind.mouse);
      final folder = await tester.runAsync(() => DocumentPlugin.getPath());
      final extension =
          artwork.metaSinglePage!.originalImageUrl!.contains('.png')
          ? '.png'
          : '.jpg';
      final filename = 'codex_mouse_check_${artwork.id}_p0$extension';
      final file = File('$folder/$filename');
      await until(() => file.existsSync() && file.lengthSync() > 0);
      await until(
        () =>
            app
                .fetcher
                .jobMaps[artwork.metaSinglePage!.originalImageUrl!]
                ?.status ==
            2,
      );
      await tester.runAsync(() async {
        final codec = await ui.instantiateImageCodec(await file.readAsBytes());
        final frame = await codec.getNextFrame();
        expect(frame.image.width, greaterThan(0));
        frame.image.dispose();
        codec.dispose();
      });
      print(
        'MOUSE_CHECK: real secondary click downloaded a valid image to the native destination',
      );
      print('DOWNLOAD_FILE: ${file.path}');

      await tester.tapAt(
        await visiblePoint(card),
        kind: PointerDeviceKind.mouse,
      );
      await screenshot('after-gallery-open');
      await until(() => find.byType(PictureListPage).evaluate().isNotEmpty);
      await secondaryClick(
        find
            .descendant(
              of: find.byType(PictureListPage),
              matching: find.byType(PixivImage),
            )
            .first,
      );
      expect(
        find.widgetWithText(PopupMenuItem<String>, labels.save),
        findsOneWidget,
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump(const Duration(milliseconds: 400));
      print('MOUSE_CHECK: artwork detail supports the same context menu');

      shell = tester.widget<DesktopShell>(find.byType(DesktopShell));
      await tester.tap(find.text(shell.labels[4]).first);
      await tester.pump(const Duration(milliseconds: 500));
      await tester.tap(find.text(labels.quality_setting));
      await until(
        () =>
            find.byType(DownloadFolderTile).evaluate().isNotEmpty &&
            find.text(folder!).evaluate().isNotEmpty,
      );
      await screenshot('download-preferences');
      print(
        'MOUSE_CHECK: Preferences displays the real native download folder',
      );

      await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyF);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
      await until(
        () => find.byType(SearchSuggestionPage).evaluate().isNotEmpty,
      );
      await tester.enterText(find.byType(TextField).first, 'landscape');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await until(
        () =>
            find.byType(ResultPage).evaluate().isNotEmpty &&
            find
                .descendant(
                  of: find.byType(ResultPage),
                  matching: find.byType(IllustCard),
                )
                .evaluate()
                .isNotEmpty,
      );
      expect(find.byType(DesktopShell), findsOneWidget);
      expect(
        tester
            .widget<TabBar>(
              find
                  .descendant(
                    of: find.byType(ResultPage),
                    matching: find.byType(TabBar),
                  )
                  .first,
            )
            .isScrollable,
        isTrue,
      );
      await screenshot('search-results-desktop');
      await windowManager.setSize(const Size(720, 560));
      await tester.pump(const Duration(seconds: 1));
      await screenshot('search-results-compact');
      expect(find.byType(DesktopShell), findsOneWidget);
      expect(tester.takeException(), isNull);
      print(
        'MOUSE_CHECK: submitted search retains desktop navigation at both window sizes',
      );
    } finally {
      settings.format = previous.$1;
      settings.fileNameEval = previous.$2;
      settings.singleFolder = previous.$3;
      settings.overSanityLevelFolder = previous.$4;
    }
  }, timeout: const Timeout(Duration(minutes: 3)));
}
