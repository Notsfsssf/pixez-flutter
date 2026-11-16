import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pixez/models/illust.dart';
import 'package:pixez/models/ugoira_metadata_response.dart';
import 'package:pixez/page/picture/ugoira_fullscreen_page.dart';
import 'package:pixez/page/picture/ugoira_store.dart';
import 'package:pixez/src/generated/i18n/app_localizations.dart';

import '../integration_test/fixtures/desktop_artworks.dart';

const _png =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAAC0lEQVR4nGP4DwQACfsD/fteaysAAAAASUVORK5CYII=';

void main() {
  testWidgets('fullscreen ugoira fills the window and follows resizes', (
    tester,
  ) async {
    final dir = await tester.runAsync(
      () => Directory.systemTemp.createTemp('ugoira_test'),
    );
    addTearDown(() => dir!.deleteSync(recursive: true));
    final frames = <File>[];
    for (var i = 0; i < 3; i++) {
      final file = File('${dir!.path}/00000$i.png');
      await tester.runAsync(() => file.writeAsBytes(base64Decode(_png)));
      frames.add(file);
    }
    final json =
        (jsonDecode(desktopArtworkJson)['illusts'] as List).first
            as Map<String, dynamic>;
    final illusts = Illusts.fromJson({...json, 'width': 600, 'height': 400});
    final store = UgoiraStore(1)
      ..drawPool = frames
      ..ugoiraMetadataResponse = UgoiraMetadataResponse.fromJson({
        'ugoira_metadata': {
          'zip_urls': {'medium': ''},
          'frames': [
            for (var i = 0; i < 3; i++) {'file': '00000$i.png', 'delay': 100},
          ],
        },
      });

    Future<Size> shownAt(Size window) async {
      tester.view.physicalSize = window;
      tester.view.devicePixelRatio = 1;
      await tester.pump();
      for (var i = 0; i < 5; i++) {
        await tester.runAsync(
          () => Future.delayed(const Duration(milliseconds: 50)),
        );
        await tester.pump(const Duration(milliseconds: 16));
      }
      return tester.getSize(find.byType(RawImage));
    }

    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: UgoiraFullscreenPage(
          illusts: illusts,
          store: store,
          onActions: () {},
        ),
      ),
    );
    expect(await shownAt(const Size(1200, 800)), const Size(1200, 800));
    // Native full screen grows the window.
    expect(await shownAt(const Size(1800, 1200)), const Size(1800, 1200));
    expect(await shownAt(const Size(900, 900)), const Size(900, 600));
  });
}
