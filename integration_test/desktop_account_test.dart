import 'dart:io';
import 'dart:ui' as ui;

import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pixez/component/illust_card.dart';
import 'package:pixez/component/star_icon.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/desktop/desktop_shell.dart';
import 'package:pixez/desktop/download_folder_tile.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/document_plugin.dart';
import 'package:pixez/main.dart' as app;
import 'package:pixez/network/api_client.dart';
import 'package:pixez/network/oauth_client.dart';
import 'package:pixez/page/account/select/account_select_page.dart';
import 'package:pixez/page/picture/picture_list_page.dart';
import 'package:window_manager/window_manager.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets('signed-in account selection, private bookmark and file download', (
    tester,
  ) async {
    // Keep credentials and account responses out of the diagnostic output.
    apiClient.httpClient.interceptors.removeWhere((i) => i is LogInterceptor);
    apiClient.httpClient.interceptors.add(InterceptorsWrapper(
      onResponse: (response, handler) {
        print('API_CHECK: ${Uri.parse(response.requestOptions.path).path} ${response.statusCode}');
        handler.next(response);
      },
      onError: (error, handler) {
        print('API_CHECK_ERROR: ${Uri.parse(error.requestOptions.path).path} ${error.response?.statusCode}');
        handler.next(error);
      },
    ));
    oAuthClient.httpClient.interceptors.removeWhere((i) => i is LogInterceptor);
    await app.main([]);
    await windowManager.show();
    await windowManager.focus();
    await windowManager.setSize(const Size(1280, 820));
    await windowManager.setAlwaysOnTop(true);
    addTearDown(() => windowManager.setAlwaysOnTop(false));

    Future<void> until(bool Function() ready) async {
      for (var i = 0; i < 300 && !ready(); i++) {
        await tester.pump(const Duration(milliseconds: 200));
      }
      expect(ready(), isTrue);
      await tester.pump(const Duration(milliseconds: 500));
    }

    Future<void> screenshot(String name) async {
      await tester.pump(const Duration(milliseconds: 500));
      await tester.runAsync(() async {
        final boundary = tester.renderObject<RenderRepaintBoundary>(
          find.byType(RepaintBoundary).first,
        );
        final image = await boundary.toImage(pixelRatio: 1);
        final data = await image.toByteData(format: ui.ImageByteFormat.png);
        final dir = Directory(
          '${(await getTemporaryDirectory()).path}/desktop-ui-proof',
        );
        await dir.create(recursive: true);
        await File(
          '${dir.path}/$name.png',
        ).writeAsBytes(data!.buffer.asUint8List());
        image.dispose();
        print('ACCOUNT_SCREENSHOT: $name');
      });
    }

    await until(
      () =>
          app.accountStore.now != null &&
          find.byType(DesktopShell).evaluate().isNotEmpty,
    );
    final shell = tester.widget<DesktopShell>(find.byType(DesktopShell));
    await tester.tap(find.text(shell.accountLabel).first);
    await until(() => find.byType(AccountSelectPage).evaluate().isNotEmpty);
    expect(find.byType(DesktopShell), findsOneWidget);
    await screenshot('account-switch');
    await tester.tap(
      find
          .descendant(
            of: find.byType(AccountSelectPage),
            matching: find.byType(ListTile),
          )
          .first,
    );
    await until(
      () =>
          find.byType(AccountSelectPage).evaluate().isEmpty &&
          find.byType(DesktopShell).evaluate().isNotEmpty,
    );
    expect(find.byType(DesktopShell), findsOneWidget);
    print('ACCOUNT_CHECK: selecting current account returns to one workspace');
    final home = tester.widget<DesktopShell>(find.byType(DesktopShell));
    await tester.tap(find.text(home.labels[0]).first);
    await tester.pump(const Duration(milliseconds: 600));
    await screenshot('home-before-contextmenu');
    await until(() => find.byType(IllustCard).evaluate().isNotEmpty);
    IllustCard? candidate;
    for (final card in tester.widgetList<IllustCard>(find.byType(IllustCard))) {
      final illust = card.store.illusts!;
      if (illust.isBookmarked ||
          illust.xRestrict != 0 ||
          illust.pageCount != 1 ||
          illust.type != 'illust')
        continue;
      final url = illust.metaSinglePage?.originalImageUrl;
      if (url == null) continue;
      final task = await tester.runAsync(
        () => app.fetcher.taskPersistProvider.getAccount(url),
      );
      if (task == null) {
        candidate = card;
        break;
      }
    }
    expect(
      candidate,
      isNotNull,
      reason:
          'Need one unbookmarked, single-page SFW recommendation not already in the download history',
    );
    final store = candidate!.store;
    final illust = store.illusts!;
    final cardFinder = find.byWidgetPredicate(
      (w) => w is IllustCard && w.store.id == store.id,
    );
    Future<Offset> visibleCardPoint() async {
      await tester.ensureVisible(cardFinder);
      await tester.pump(const Duration(milliseconds: 400));
      final pane = tester.getRect(find.byType(Navigator).last);
      final visible = tester
          .getRect(cardFinder)
          .intersect(
            Rect.fromLTRB(pane.left, pane.top + 120, pane.right, pane.bottom),
          );
      expect(visible.isEmpty, isFalse);
      return visible.center;
    }

    final settings = app.userSetting;
    final previous = (
      settings.defaultPrivateLike,
      settings.saveAfterStar,
      settings.followAfterStar,
      settings.autoTagWhenStar,
      settings.starAfterSave,
      settings.longPressSaveConfirm,
      settings.format,
      settings.fileNameEval,
      settings.singleFolder,
      settings.overSanityLevelFolder,
    );
    settings.defaultPrivateLike = true;
    settings.saveAfterStar = false;
    settings.followAfterStar = false;
    settings.autoTagWhenStar = false;
    settings.starAfterSave = false;
    settings.longPressSaveConfirm = false;
    settings.format = 'codex_download_check_{illust_id}_p{part}';
    settings.fileNameEval = 0;
    settings.singleFolder = false;
    settings.overSanityLevelFolder = false;

    Future<Map<String, dynamic>> bookmarkDetail() async {
      final response = await apiClient.httpClient.get(
        '/v2/illust/bookmark/detail',
        queryParameters: {'illust_id': store.id},
        options: apiClient.options
            .copyWith(policy: CachePolicy.refresh)
            .toOptions(),
      );
      return Map<String, dynamic>.from(response.data['bookmark_detail']);
    }

    try {
      final star = find
          .descendant(of: cardFinder, matching: find.byType(StarIcon))
          .first;
      await Scrollable.ensureVisible(tester.element(star), alignment: 0.5);
      await tester.pump(const Duration(milliseconds: 400));
      await tester.tap(star);
      await until(() => store.state != 1 && illust.isBookmarked);
      final detail = await tester.runAsync(bookmarkDetail);
      expect(detail!['is_bookmarked'], isTrue);
      expect(detail['restrict'], 'private');
      print('ACCOUNT_CHECK: UI bookmark confirmed private by server');

      await Scrollable.ensureVisible(tester.element(star), alignment: 0.5);
      await tester.pump(const Duration(milliseconds: 400));
      await tester.tap(star);
      await until(() => store.state == 0 && !illust.isBookmarked);
      final removed = await tester.runAsync(bookmarkDetail);
      expect(removed!['is_bookmarked'], isFalse);
      print('ACCOUNT_CHECK: temporary bookmark removed and server confirmed');

      await tester.tapAt(
        await visibleCardPoint(),
        buttons: kSecondaryMouseButton,
        kind: PointerDeviceKind.mouse,
      );
      await tester.pump(const Duration(milliseconds: 400));
      final downloadLabel = I18n.of(tester.element(cardFinder)).save;
      expect(
        find.widgetWithText(PopupMenuItem<String>, downloadLabel),
        findsOneWidget,
      );
      await screenshot('artwork-right-click');
      await tester.tap(
        find.widgetWithText(PopupMenuItem<String>, downloadLabel),
      );
      final extension =
          illust.metaSinglePage!.originalImageUrl!.contains('.png')
          ? '.png'
          : '.jpg';
      final filename = 'codex_download_check_${store.id}_p0$extension';
      final directory = await tester.runAsync(() => DocumentPlugin.getPath());
      expect(directory, isNotNull);
      final file = File('$directory/$filename');
      await until(() => file.existsSync() && file.lengthSync() > 0);
      final task = await tester.runAsync(
        () => app.fetcher.taskPersistProvider.getAccount(
          illust.metaSinglePage!.originalImageUrl!,
        ),
      );
      // The task status must reflect the persisted file, rather than network completion alone.
      for (var i = 0; i < 20 && task?.status != 2; i++) {
        await tester.pump(const Duration(milliseconds: 200));
      }
      final complete = await tester.runAsync(
        () => app.fetcher.taskPersistProvider.getAccount(
          illust.metaSinglePage!.originalImageUrl!,
        ),
      );
      expect(complete!.status, 2);
      expect(
        await tester.runAsync(() => DocumentPlugin.exist(filename)),
        isTrue,
      );
      final codec = await ui.instantiateImageCodec(await file.readAsBytes());
      final frame = await codec.getNextFrame();
      expect(frame.image.width, greaterThan(0));
      frame.image.dispose();
      codec.dispose();
      print(
        'ACCOUNT_CHECK: downloaded image exists, decodes, and task is complete',
      );
      print('DOWNLOAD_FILE: ${file.path}');

      await tester.tapAt(await visibleCardPoint());
      await until(() => find.byType(PictureListPage).evaluate().isNotEmpty);
      expect(find.byType(DesktopShell), findsOneWidget);
      await screenshot('signed-in-artwork');
      final detailImage = find
          .descendant(
            of: find.byType(PictureListPage),
            matching: find.byType(PixivImage),
          )
          .first;
      final imageRect = tester
          .getRect(detailImage)
          .intersect(tester.getRect(find.byType(Navigator).last));
      await tester.tapAt(
        imageRect.center,
        buttons: kSecondaryMouseButton,
        kind: PointerDeviceKind.mouse,
      );
      await tester.pump(const Duration(milliseconds: 400));
      expect(
        find.widgetWithText(PopupMenuItem<String>, downloadLabel),
        findsOneWidget,
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump(const Duration(milliseconds: 400));
      final desktop = tester.widget<DesktopShell>(find.byType(DesktopShell));
      await tester.tap(find.text(desktop.labels[4]).first);
      await tester.pump(const Duration(milliseconds: 500));
      final preferencesLabel = I18n.of(
        tester.element(find.byType(DesktopShell)),
      ).quality_setting;
      await tester.tap(find.text(preferencesLabel));
      await until(() => find.byType(DownloadFolderTile).evaluate().isNotEmpty);
      await until(() => find.text(directory!).evaluate().isNotEmpty);
      await screenshot('download-preferences');
      expect(tester.takeException(), isNull);
    } finally {
      // Never leave the test artwork bookmarked or persist changed preferences.
      if (illust.isBookmarked) await tester.runAsync(() => store.star());
      settings.defaultPrivateLike = previous.$1;
      settings.saveAfterStar = previous.$2;
      settings.followAfterStar = previous.$3;
      settings.autoTagWhenStar = previous.$4;
      settings.starAfterSave = previous.$5;
      settings.longPressSaveConfirm = previous.$6;
      settings.format = previous.$7;
      settings.fileNameEval = previous.$8;
      settings.singleFolder = previous.$9;
      settings.overSanityLevelFolder = previous.$10;
    }
  }, timeout: const Timeout(Duration(minutes: 4)));
}
