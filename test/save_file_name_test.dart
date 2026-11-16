import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixez/document_plugin.dart';
import 'package:pixez/exts.dart';
import 'package:pixez/js_eval_plugin.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/illust.dart';
import 'package:pixez/saf_plugin.dart';
import 'package:pixez/store/save_store.dart';
import 'package:pixez/store/user_setting.dart';
import 'package:pixez/utils/file_name.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  final illust = Illusts(
    id: 123,
    title: '夏日😭',
    type: 'illust',
    imageUrls: ImageUrls(squareMedium: '', medium: '', large: ''),
    caption: '',
    restrict: 0,
    user: User(
      id: 42,
      name: '画师 🧑🏽‍💻',
      account: 'artist',
      profileImageUrls: ProfileImageUrls(medium: ''),
    ),
    tags: [],
    tools: [],
    createDate: '',
    pageCount: 2,
    width: 1,
    height: 1,
    sanityLevel: 0,
    xRestrict: 0,
    metaPages: [],
    totalView: 0,
    totalBookmarks: 0,
    isBookmarked: false,
    visible: true,
    isMuted: false,
    illustAIType: 0,
    totalComments: 0,
  );

  setUp(() {
    userSetting.format = '{illust_id}_p{part} {title}';
    userSetting.fileNameEval = 0;
    userSetting.nameEval = null;
    userSetting.singleFolder = false;
    userSetting.filenameEmojiMode = FilenameEmojiMode.underscore;
    userSetting.filenameEmojiCapitalize = false;
  });

  tearDown(() {
    messenger.setMockMethodCallHandler(DocumentPlugin.platform, null);
    messenger.setMockMethodCallHandler(JSEvalPlugin.platform, null);
    messenger.setMockMethodCallHandler(SAFPlugin.platform, null);
  });

  test('template names preserve spaces, page numbers and extensions', () async {
    for (final extension in ['.jpg', '.png', '.gif', '.zip']) {
      expect(
        await buildSaveFileName(illust, 1, extension),
        '123_p1 夏日_$extension',
      );
    }
    expect(
      await buildSaveFileName(illust, 1, '.jpg', withExtension: false),
      '123_p1 夏日_',
    );
    expect(illust.title, '夏日😭');
    expect(illust.user.name, '画师 🧑🏽‍💻');
  });

  test('author folders use the same cleanup as filenames', () async {
    userSetting.singleFolder = true;
    final name = await buildSaveFileName(illust, 0, '.jpg');
    expect(applySingleFolder(illust, name), '画师 __42/123_p0 夏日_.jpg');
  });

  test(
    'JS names are cleaned while preserving their directory structure',
    () async {
      userSetting.fileNameEval = 1;
      userSetting.nameEval = 'custom script';
      messenger.setMockMethodCallHandler(
        JSEvalPlugin.platform,
        (_) async => '画师🧑🏽‍💻/123_p1 夏日😭.jpg',
      );
      expect(await buildSaveFileName(illust, 1, '.jpg'), '画师_/123_p1 夏日_.jpg');
      expect(
        await saveStore.testEvalName('custom script', illust, 1, '.jpg'),
        '画师_/123_p1 夏日_.jpg',
      );
    },
  );

  test(
    'keycaps are replaced before illegal filename characters are removed',
    () {
      expect('a *️⃣ #️⃣ 1️⃣/\\:*?<>|"\u0000.jpg'.toLegal(), 'a _ _ _.jpg');
    },
  );

  test('save and existence channels receive the same cleaned path', () async {
    final calls = <MethodCall>[];
    messenger.setMockMethodCallHandler(DocumentPlugin.platform, (call) async {
      calls.add(call);
      return true;
    });
    final bytes = Uint8List.fromList([1, 2, 3]);
    const name = '画师🧑🏽‍💻/123_p0 夏日😭.jpg';
    const source = '/cache/原图😭.gif';
    await DocumentPlugin.exist(name, saveMode: 1);
    await DocumentPlugin.save(bytes, name, saveMode: 1);
    await DocumentPlugin.saveFromPath(source, name, saveMode: 1);
    await DocumentPlugin.openSave(bytes, name);

    expect(calls.map((call) => call.method), [
      'exist',
      'save',
      'saveFromPath',
      'openSave',
    ]);
    for (final call in calls) {
      expect(call.arguments['name'], '画师_/123_p0 夏日_.jpg');
    }
    expect(calls[1].arguments['data'], bytes);
    expect(calls[2].arguments['source_path'], source);
  });

  test(
    'English preferences also apply at direct save and lookup boundaries',
    () async {
      userSetting.filenameEmojiMode = FilenameEmojiMode.english;
      userSetting.filenameEmojiCapitalize = true;
      final calls = <MethodCall>[];
      messenger.setMockMethodCallHandler(DocumentPlugin.platform, (call) async {
        calls.add(call);
        return true;
      });
      await DocumentPlugin.save(Uint8List(0), '🐟️.jpg', saveMode: 1);
      await DocumentPlugin.exist('🐟️.jpg', saveMode: 1);
      expect(calls.map((call) => call.arguments['name']), [
        'Fish.jpg',
        'Fish.jpg',
      ]);
    },
  );

  test('SAF export cleans the display name before file creation', () async {
    MethodCall? createCall;
    messenger.setMockMethodCallHandler(SAFPlugin.platform, (call) async {
      createCall = call;
      return 'content://documents/export';
    });
    expect(
      await SAFPlugin.createFile('夏日😭.zip', 'application/zip'),
      'content://documents/export',
    );
    expect(createCall!.arguments['name'], '夏日_.zip');
    expect(createCall!.arguments['mimeType'], 'application/zip');
  });

  test(
    'English preferences persist and apply to template and author names',
    () async {
      SharedPreferences.setMockInitialValues({});
      userSetting.prefs = await SharedPreferences.getInstance();
      await userSetting.setFilenameEmojiMode(FilenameEmojiMode.english);
      await userSetting.setFilenameEmojiCapitalize(true);
      expect(userSetting.prefs.getString('filename_emoji_mode'), 'english');
      expect(userSetting.prefs.getBool('filename_emoji_capitalize'), true);
      final restored = UserSetting()..pictureSource = 'test.invalid';
      await restored.init();
      expect(restored.filenameEmojiMode, FilenameEmojiMode.english);
      expect(restored.filenameEmojiCapitalize, isTrue);
      expect(restored.sanitizeFileName('🐟️.jpg'), 'Fish.jpg');
      expect(
        await buildSaveFileName(illust, 0, '.jpg'),
        '123_p0 夏日Loudly_crying_face.jpg',
      );
      userSetting.singleFolder = true;
      expect(
        applySingleFolder(illust, '123.jpg'),
        '画师 Technologist_medium_skin_tone_42/123.jpg',
      );
    },
  );
}
