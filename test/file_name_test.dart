import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pixez/utils/file_name.dart';

void main() {
  group('replaceFilenameEmoji', () {
    final cases = <String, String>{
      '123_p0 标题😭.jpg': '123_p0 标题_.jpg',
      '123_p1 ☀️和❤.png': '123_p1 _和_.png',
      '作者🧑🏽‍💻_42/123_p0.jpg': '作者__42/123_p0.jpg',
      '家人👨‍👩‍👧‍👦.gif': '家人_.gif',
      '旗帜🏳️‍🌈.zip': '旗帜_.zip',
      '国旗🇨🇳.jpg': '国旗_.jpg',
      '旗帜\u{1F3F4}\u{E0067}\u{E0062}\u{E0065}\u{E006E}\u{E0067}\u{E007F}.jpg':
          '旗帜_.jpg',
      '1️⃣ #️⃣ *️⃣.jpg': '_ _ _.jpg',
      '1\u20E3.jpg': '_.jpg',
      '😭': '_',
      '😭😂.jpg': '_.jpg',
      '2026 #1 (2) + 3.jpg': '2026 #1 (2) + 3.jpg',
      ' 空格  中文 日本語 한글 café e\u0301 𠮷 𝄞 .jpg':
          ' 空格  中文 日本語 한글 café e\u0301 𠮷 𝄞 .jpg',
      'نیم\u200Cفاصله.jpg': 'نیم\u200Cفاصله.jpg',
      '': '',
    };

    for (final entry in cases.entries) {
      test(entry.key.isEmpty ? 'empty name' : entry.key, () {
        expect(replaceFilenameEmoji(entry.key), entry.value);
        // Names may pass through generation, queuing and the save channel.
        expect(replaceFilenameEmoji(entry.value), entry.value);
      });
    }
  });

  test(
    'English names support presentation selectors and first-letter case',
    () {
      expect(
        replaceFilenameEmoji('🐟️.jpg', mode: FilenameEmojiMode.english),
        'fish.jpg',
      );
      expect(
        replaceFilenameEmoji(
          '🐟️.jpg',
          mode: FilenameEmojiMode.english,
          capitalize: true,
        ),
        'Fish.jpg',
      );
      expect(
        replaceFilenameEmoji('🐟🐱🧑‍💻.jpg', mode: FilenameEmojiMode.english),
        'fish_cat_face_technologist.jpg',
      );
      expect(
        replaceFilenameEmoji(
          '🧑🏽‍💻.jpg',
          mode: FilenameEmojiMode.english,
          capitalize: true,
        ),
        'Technologist_medium_skin_tone.jpg',
      );
      expect(
        replaceFilenameEmoji('1️⃣#️⃣*️⃣.jpg', mode: FilenameEmojiMode.english),
        'keycap_1_keycap_hash_keycap_asterisk.jpg',
      );
    },
  );

  test('removal mode preserves the surrounding text and spaces', () {
    expect(
      replaceFilenameEmoji(
        '标题 🐟️ 🧑🏽‍💻 123_p1.jpg',
        mode: FilenameEmojiMode.remove,
      ),
      '标题   123_p1.jpg',
    );
  });

  test('removal cannot turn emoji-only components into empty names', () {
    expect(
      replaceFilenameEmoji('🐟/😭.jpg', mode: FilenameEmojiMode.remove),
      '_/_.jpg',
    );
    expect(
      replaceFilenameEmoji(r'🐟\😭.jpg', mode: FilenameEmojiMode.remove),
      r'_\_.jpg',
    );
    expect(replaceFilenameEmoji('🐟', mode: FilenameEmojiMode.remove), '_');
    expect(
      replaceFilenameEmoji('.🐟./file.jpg', mode: FilenameEmojiMode.remove),
      '_/file.jpg',
    );
  });

  test(
    'unrecognized pictographs fall back to an underscore in English mode',
    () {
      expect(
        replaceFilenameEmoji(
          'new\u{1FAFF}.jpg',
          mode: FilenameEmojiMode.english,
        ),
        'new_.jpg',
      );
    },
  );

  test('English output is unchanged when cleaned again', () {
    const original = '作者🧑🏽‍💻/🐟️ 𠮷 123_p0.jpg';
    final name = replaceFilenameEmoji(
      original,
      mode: FilenameEmojiMode.english,
      capitalize: true,
    );
    expect(
      replaceFilenameEmoji(
        name,
        mode: FilenameEmojiMode.english,
        capitalize: true,
      ),
      name,
    );
    expect(name, '作者Technologist_medium_skin_tone/Fish 𠮷 123_p0.jpg');
  });

  test('the same name works for writing and duplicate detection', () async {
    final directory = await Directory.systemTemp.createTemp('pixez_filename_');
    addTearDown(() => directory.delete(recursive: true));
    const original = '作者🧑🏽‍💻_42/123_p0 标题😭.jpg';
    final name = replaceFilenameEmoji(original);
    final file = File('${directory.path}/$name');
    await file.parent.create(recursive: true);
    await file.writeAsBytes([1, 2, 3]);

    expect(name, '作者__42/123_p0 标题_.jpg');
    expect(
      await File(
        '${directory.path}/${replaceFilenameEmoji(original)}',
      ).exists(),
      isTrue,
    );
    expect(await file.readAsBytes(), [1, 2, 3]);
  });
}
