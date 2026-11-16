import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pixez/document_plugin.dart';
import 'package:pixez/main.dart';
import 'package:pixez/page/hello/setting/save_format_page.dart';
import 'package:pixez/page/platform/platform_page.dart';
import 'package:pixez/src/generated/i18n/app_localizations.dart';
import 'package:pixez/utils/file_name.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  const displayChannel = MethodChannel('flutter_display_mode');

  Widget app(Widget home) => MaterialApp(
    locale: const Locale('zh', 'CN'),
    localizationsDelegates: [
      AppLocalizations.delegate,
      ...GlobalMaterialLocalizations.delegates,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: home,
  );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    userSetting.prefs = await SharedPreferences.getInstance();
    userSetting.filenameEmojiMode = FilenameEmojiMode.underscore;
    userSetting.filenameEmojiCapitalize = false;
    PackageInfo.setMockInitialValues(
      appName: 'Pixez',
      packageName: 'com.perol.pixez',
      version: '1.9.89',
      buildNumber: '514',
      buildSignature: '',
    );
    DeviceInfoPlugin.setMockInitialValues(
      androidDeviceInfo: AndroidDeviceInfo.fromMap({
        'version': {
          'sdkInt': 29,
          'release': '10',
          'incremental': '',
          'codename': 'REL',
        },
        'board': '',
        'bootloader': '',
        'brand': 'test',
        'device': '',
        'display': '',
        'fingerprint': '',
        'hardware': '',
        'host': '',
        'id': '',
        'manufacturer': 'test',
        'model': 'test',
        'product': '',
        'tags': '',
        'time': 0,
        'type': 'user',
        'isPhysicalDevice': false,
        'freeDiskSize': 1024,
        'totalDiskSize': 2048,
        'isLowRamDevice': false,
        'physicalRamSize': 1024,
        'availableRamSize': 512,
      }),
    );
    messenger.setMockMethodCallHandler(
      DocumentPlugin.platform,
      (_) async => '/Pictures/pixez',
    );
    messenger.setMockMethodCallHandler(displayChannel, (call) async {
      if (call.method == 'getSupportedModes') return [];
      return {'id': 0, 'width': 0, 'height': 0, 'refreshRate': 0.0};
    });
  });

  tearDown(() {
    messenger.setMockMethodCallHandler(DocumentPlugin.platform, null);
    messenger.setMockMethodCallHandler(displayChannel, null);
  });

  testWidgets(
    'mode and capitalization controls update the preview on a phone',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(app(PlatformPage()));
      await tester.pumpAndSettle();
      expect(find.text('🐟️.jpg → _.jpg'), findsOneWidget);
      await tester.tap(find.byType(DropdownButton<FilenameEmojiMode>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('英文名称').last);
      await tester.pumpAndSettle();
      expect(find.text('🐟️.jpg → fish.jpg'), findsOneWidget);
      await tester.tap(find.text('每个表情的英文名称首字母大写'));
      await tester.pumpAndSettle();
      expect(find.text('🐟️.jpg → Fish.jpg'), findsOneWidget);
      expect(userSetting.prefs.getBool('filename_emoji_capitalize'), isTrue);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('the naming editor accepts and saves spaces', (tester) async {
    String? result;
    await tester.pumpWidget(
      app(
        Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              result = await Navigator.of(context).push<String>(
                MaterialPageRoute(builder: (_) => SaveFormatPage()),
              );
            },
            child: const Text('Open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    const format = '{illust_id} p{part} {title}';
    await tester.enterText(find.byType(TextField), format);
    await tester.pump();
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      format,
    );
    await tester.tap(find.byIcon(Icons.save));
    await tester.pumpAndSettle();
    expect(result, format);
    expect(tester.takeException(), isNull);
  });
}
