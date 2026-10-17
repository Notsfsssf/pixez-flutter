import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pixez/exts.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/illust.dart';

Illusts _illust({required List<String> tags, required int xRestrict}) {
  const imageUrls = {
    'square_medium': 'https://i.pximg.net/square.jpg',
    'medium': 'https://i.pximg.net/medium.jpg',
    'large': 'https://i.pximg.net/large.jpg',
  };
  return Illusts.fromJson(jsonDecode(jsonEncode({
    'id': 1,
    'title': 'title',
    'type': 'illust',
    'image_urls': imageUrls,
    'caption': '',
    'restrict': 0,
    'user': {
      'id': 2,
      'name': 'user',
      'account': 'user',
      'profile_image_urls': {'medium': 'https://i.pximg.net/avatar.jpg'},
      'is_followed': false,
    },
    'tags': [
      for (final tag in tags) {'name': tag, 'translated_name': null},
    ],
    'tools': [],
    'create_date': '2026-01-01T00:00:00+09:00',
    'page_count': 1,
    'width': 100,
    'height': 100,
    'sanity_level': 2,
    'x_restrict': xRestrict,
    'meta_single_page': {},
    'meta_pages': [],
    'total_view': 0,
    'total_bookmarks': 0,
    'is_bookmarked': false,
    'visible': true,
    'is_muted': false,
    'total_comments': 0,
    'illust_ai_type': 1,
  })));
}

void main() {
  tearDown(() => userSetting.hIsNotAllow = false);

  group('Illusts.hIsNotAllow', () {
    test('is false when R-18 is allowed', () {
      userSetting.hIsNotAllow = false;
      expect(_illust(tags: ['R-18'], xRestrict: 1).hIsNotAllow(), isFalse);
    });

    test('hides works tagged R-18 or R-18G', () {
      userSetting.hIsNotAllow = true;
      expect(_illust(tags: ['R-18'], xRestrict: 0).hIsNotAllow(), isTrue);
      expect(_illust(tags: ['R-18G'], xRestrict: 0).hIsNotAllow(), isTrue);
    });

    test('hides works flagged by x_restrict even without the tag (#1360)', () {
      userSetting.hIsNotAllow = true;
      expect(_illust(tags: [], xRestrict: 1).hIsNotAllow(), isTrue);
      expect(_illust(tags: [], xRestrict: 2).hIsNotAllow(), isTrue);
    });

    test('keeps all-ages works visible', () {
      userSetting.hIsNotAllow = true;
      expect(_illust(tags: ['オリジナル'], xRestrict: 0).hIsNotAllow(), isFalse);
    });
  });
}
