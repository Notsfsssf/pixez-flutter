import 'dart:io';
import 'dart:ui' as ui;
import 'package:dio/dio.dart';

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pixez/desktop/desktop_shell.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/component/illust_card.dart';
import 'package:pixez/page/picture/picture_list_page.dart';
import 'package:pixez/main.dart' as app;
import 'package:pixez/network/api_client.dart';
import 'package:pixez/network/oauth_client.dart';
import 'package:pixez/page/hello/recom/recom_spotlight_page.dart';
import 'package:waterfall_flow/waterfall_flow.dart';
import 'package:pixez/page/history/history_page.dart';
import 'package:pixez/page/preview/preview_page.dart';
import 'package:pixez/page/novel/novel_rail.dart';
import 'package:pixez/constants.dart';
import 'package:pixez/page/search/suggest/search_suggestion_page.dart';
import 'package:pixez/page/search/result_page.dart';
import 'package:pixez/page/task/job_page.dart';
import 'package:window_manager/window_manager.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets('macOS desktop navigation and responsive layout', (tester) async {
    apiClient.httpClient.interceptors.removeWhere((i) => i is LogInterceptor);
    oAuthClient.httpClient.interceptors.removeWhere((i) => i is LogInterceptor);
    await app.main([]);
    await windowManager.setSize(const Size(1280, 820));
    await windowManager.show();
    await windowManager.focus();
    await windowManager.setAlwaysOnTop(true);
    addTearDown(() => windowManager.setAlwaysOnTop(false));

    Future<void> waitFor(Finder finder) async {
      for (var i = 0; i < 150 && finder.evaluate().isEmpty; i++) {
        await tester.pump(const Duration(milliseconds: 200));
      }
      expect(finder, findsWidgets);
      await tester.pump(const Duration(milliseconds: 500));
    }

    Future<void> screenshot(String name) async {
      await tester.pump(const Duration(milliseconds: 500));
      await tester.runAsync(() async {
        print('DESKTOP_CAPTURING: $name');
        final boundary = tester.renderObject<RenderRepaintBoundary>(
          find.byType(RepaintBoundary).first,
        );
        final image = await boundary.toImage(pixelRatio: 1);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        final directory = Directory(
          '${(await getTemporaryDirectory()).path}/desktop-ui-proof',
        );
        await directory.create(recursive: true);
        final file = File('${directory.path}/$name.png');
        await file.writeAsBytes(bytes!.buffer.asUint8List());
        image.dispose();
        // The host can collect images from the app's sandbox after the run.
        print('DESKTOP_SCREENSHOT: ${file.path}');
      });
    }

    // Complete the normal first-run guide if this is a fresh installation.
    for (var i = 0; i < 150; i++) {
      await tester.pump(const Duration(milliseconds: 200));
      if (find.text('NEXT').evaluate().isNotEmpty ||
          find.byType(DesktopShell).evaluate().isNotEmpty)
        break;
    }
    // HelloPage schedules the first-run guide on the next frame. Do not
    // mistake that briefly mounted shell for the completed home screen.
    await tester.pump(const Duration(seconds: 1));
    if (find.text('NEXT').evaluate().isNotEmpty) {
      await tester.tap(find.text('NEXT'));
      await tester.pump(const Duration(seconds: 1));
      await tester.tap(find.text('NEXT'));
    }
    await waitFor(find.byType(DesktopShell));
    final initialWorkspace = tester.widget<DesktopShell>(find.byType(DesktopShell));
    await tester.tap(find.text(initialWorkspace.labels[0]).first);
    await tester.pump(const Duration(milliseconds: 500));
    if (app.accountStore.now == null) {
      await waitFor(
        find.descendant(
          of: find.byType(PreviewPage),
          matching: find.byType(PixivImage),
        ),
      );
      await screenshot('home-wide');

      final artwork = find
          .descendant(
            of: find.byType(PreviewPage),
            matching: find.byType(PixivImage),
          )
          .first;
      await tester.tap(artwork);
      await waitFor(find.byType(GoToLoginPage));
      await screenshot('artwork-detail');
      await tester.tap(find.byIcon(Icons.arrow_back).first);
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.byType(GoToLoginPage), findsNothing);
    } else {
      await waitFor(find.byType(IllustCard));
      await screenshot('home-wide');
      final card = find.byType(IllustCard).first;
      final image = find
          .descendant(of: card, matching: find.byType(PixivImage))
          .first;
      await tester.ensureVisible(image);
      await tester.tap(image);
      await waitFor(find.byType(PictureListPage));
      expect(find.byType(DesktopShell), findsOneWidget);
      await screenshot('artwork-detail');
      await tester.tap(find.byIcon(Icons.arrow_back).first);
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.byType(PictureListPage), findsNothing);
    }

    // Exercise the real PageController through each sidebar destination.
    for (var i = 1; i < 5; i++) {
      final shell = tester.widget<DesktopShell>(find.byType(DesktopShell));
      await tester.tap(find.text(shell.labels[i]).first);
      await tester.pump(const Duration(milliseconds: 600));
      expect(
        tester.widget<DesktopShell>(find.byType(DesktopShell)).selectedIndex,
        i,
      );
      expect(tester.takeException(), isNull);
    }
    await screenshot('settings-wide');

    // Real database-backed pages should remain inside the desktop frame.
    for (final page in [HistoryPage, JobPage]) {
      final shell = tester.widget<DesktopShell>(find.byType(DesktopShell));
      final link = shell.links[page == HistoryPage ? 0 : 1];
      await tester.tap(find.text(link.label).first);
      await waitFor(find.byType(page));
      expect(find.byType(DesktopShell), findsOneWidget);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.bracketLeft);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.byType(page), findsNothing);
    }

    await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyF);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
    await waitFor(find.byType(SearchSuggestionPage));
    await tester.enterText(find.byType(TextField).first, 'landscape');
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.text('landscape'), findsWidgets);
    await screenshot('search-wide');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await waitFor(find.byType(ResultPage));
    expect(find.byType(DesktopShell), findsOneWidget);
    await waitFor(
      find.descendant(
        of: find.byType(ResultPage),
        matching: find.byType(IllustCard),
      ),
    );
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

    // Switching from a detail route returns to the selected root tab.
    await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.digit1);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(SearchSuggestionPage), findsNothing);
    expect(
      tester.widget<DesktopShell>(find.byType(DesktopShell)).selectedIndex,
      0,
    );

    await windowManager.setSize(const Size(720, 560));
    await tester.pump(const Duration(seconds: 1));
    await screenshot('home-compact');
    if (app.accountStore.now != null &&
        app.userSetting.hCrossCount == 4 &&
        !app.userSetting.hCrossAdapt) {
      final gallery = tester.widget<SliverWaterfallFlow>(
        find
            .descendant(
              of: find.byType(RecomSpolightPage),
              matching: find.byType(SliverWaterfallFlow),
            )
            .first,
      );
      final grid =
          gallery.gridDelegate
              as SliverWaterfallFlowDelegateWithFixedCrossAxisCount;
      expect(
        grid.crossAxisCount,
        2,
        reason: 'A narrow desktop pane must not retain four tiny columns',
      );
    }
    expect(tester.takeException(), isNull);
    await windowManager.setSize(const Size(1280, 820));
    await tester.pump(const Duration(seconds: 1));
    final shell = tester.widget<DesktopShell>(find.byType(DesktopShell));
    await tester.tap(find.text(shell.links[2].label).first);
    await waitFor(find.byType(NovelRail));
    expect(Constants.type, 1);
    expect(find.byType(DesktopShell), findsNothing);
    await tester.tap(find.byIcon(Icons.picture_in_picture));
    await waitFor(find.byType(DesktopShell));
    expect(Constants.type, 0);
    expect(find.byType(NovelRail), findsNothing);
    await screenshot('home-final');
  });
}
