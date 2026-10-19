import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/illust.dart';
import 'package:pixez/store/save_store.dart';

Illusts _illust({String title = 'title', required String createDate}) {
  const imageUrls = {
    'square_medium': 'https://i.pximg.net/square.jpg',
    'medium': 'https://i.pximg.net/medium.jpg',
    'large': 'https://i.pximg.net/large.jpg',
  };
  return Illusts.fromJson(jsonDecode(jsonEncode({
    'id': 123,
    'title': title,
    'type': 'illust',
    'image_urls': imageUrls,
    'caption': '',
    'restrict': 0,
    'user': {
      'id': 456,
      'name': 'user',
      'account': 'user',
      'profile_image_urls': {'medium': 'https://i.pximg.net/avatar.jpg'},
      'is_followed': false,
    },
    'tags': [],
    'tools': [],
    'create_date': createDate,
    'page_count': 1,
    'width': 100,
    'height': 100,
    'sanity_level': 2,
    'x_restrict': 0,
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
  setUp(() {
    userSetting.fileNameEval = 0;
  });

  test('keeps existing tags unchanged', () async {
    userSetting.format = '{illust_id}_{user_id}_{user_name}_{title}_p{part}';
    final name = await buildSaveFileName(
      _illust(createDate: '2024-12-26T01:27:47+09:00'),
      2,
      '.png',
    );
    expect(name, '123_456_user_title_p2.png');
  });

  test('replaces upload date tags with the date shown on pixiv (#1293)',
      () async {
    userSetting.format = '{year}-{month}-{day}_{illust_id}_p{part}';
    final name = await buildSaveFileName(
      // 01:27 JST is still the previous day in UTC; keep the pixiv date.
      _illust(createDate: '2024-12-26T01:27:47+09:00'),
      0,
      '.jpg',
    );
    expect(name, '2024-12-26_123_p0.jpg');
  });

  test('does not expand date tags written inside the title', () async {
    userSetting.format = '{title}_p{part}';
    final name = await buildSaveFileName(
      _illust(title: 'my {year}', createDate: '2024-12-26T01:27:47+09:00'),
      0,
      '.jpg',
    );
    expect(name, 'my {year}_p0.jpg');
  });
}
