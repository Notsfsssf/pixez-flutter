import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pixez/desktop/download_folder_tile.dart';
import 'package:pixez/document_plugin.dart';
import 'package:pixez/src/generated/i18n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget preferences() => MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: [
      AppLocalizations.delegate,
      ...GlobalMaterialLocalizations.delegates,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: const Scaffold(body: DownloadFolderTile()),
  );

  tearDown(
    () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(DocumentPlugin.platform, null),
  );

  testWidgets(
    'folder choice updates visible path and survives reopening preferences',
    (tester) async {
      var path = '/Downloads/PixEz';
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(DocumentPlugin.platform, (call) async {
            if (call.method == 'get_path') return path;
            if (call.method == 'choice_folder')
              return path = '/Pictures/My artwork';
            return null;
          });
      await tester.pumpWidget(preferences());
      await tester.pumpAndSettle();
      expect(find.text(path), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('download-folder')));
      await tester.pumpAndSettle();
      expect(find.text('/Pictures/My artwork'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(preferences());
      await tester.pumpAndSettle();
      expect(find.text('/Pictures/My artwork'), findsOneWidget);
    },
  );

  testWidgets('cancelling folder picker keeps the existing destination', (
    tester,
  ) async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          DocumentPlugin.platform,
          (call) async => call.method == 'get_path' ? '/Downloads/PixEz' : null,
        );
    await tester.pumpWidget(preferences());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('download-folder')));
    await tester.pumpAndSettle();
    expect(find.text('/Downloads/PixEz'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
