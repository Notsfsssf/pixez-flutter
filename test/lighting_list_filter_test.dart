import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixez/lighting/lighting_page.dart';
import 'package:pixez/lighting/lighting_store.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/src/generated/i18n/app_localizations.dart';

const _nextUrlPrefix = 'https://app-api.pixiv.net/v1/search/illust?offset=';

Map<String, dynamic> _illustJson(int id, String type) {
  const imageUrls = {
    'square_medium': 'https://i.pximg.net/square.jpg',
    'medium': 'https://i.pximg.net/medium.jpg',
    'large': 'https://i.pximg.net/large.jpg',
  };
  return {
    'id': id,
    'title': 'title $id',
    'type': type,
    'image_urls': imageUrls,
    'caption': '',
    'restrict': 0,
    'user': {
      'id': 1,
      'name': 'user',
      'account': 'user',
      'profile_image_urls': {'medium': 'https://i.pximg.net/avatar.jpg'},
      'is_followed': false,
    },
    'tags': [
      {'name': 'tag', 'translated_name': null},
    ],
    'tools': [],
    'create_date': '2026-01-01T00:00:00+09:00',
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
  };
}

// Round-trip through JSON so the maps have the same types as API responses.
Map<String, dynamic> _page(int offset, {required bool hasNext}) => jsonDecode(
  jsonEncode({
    'illusts': [
      for (var i = 0; i < 3; i++) _illustJson(offset + i + 1, 'illust'),
    ],
    'next_url': hasNext ? '$_nextUrlPrefix${offset + 30}' : null,
  }),
);

/// Serves `getNext` requests locally and records them.
List<Uri> _fakeNextPages({required int lastOffset}) {
  final requests = <Uri>[];
  apiClient.httpClient = Dio(BaseOptions(baseUrl: 'https://app-api.pixiv.net'))
    ..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          requests.add(options.uri);
          final offset = int.parse(options.uri.queryParameters['offset']!);
          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 200,
              data: _page(offset, hasNext: offset < lastOffset),
            ),
          );
        },
      ),
    );
  return requests;
}

Future<void> _pumpList(WidgetTester tester, LightingList list) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: list),
    ),
  );
  for (var i = 0; i < 30; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

LightSource _firstPageSource() => ApiForceSource(
  futureGet: (_) async => Response(
    requestOptions: RequestOptions(path: '/v1/search/illust'),
    statusCode: 200,
    data: _page(0, hasNext: true),
  ),
);

bool _onlyUgoira(illust) => illust.type == 'ugoira';

void main() {
  testWidgets('loads next pages while the filter hides every item', (
    tester,
  ) async {
    final requests = _fakeNextPages(lastOffset: 60);

    await _pumpList(
      tester,
      LightingList(source: _firstPageSource(), filter: _onlyUgoira),
    );

    expect(requests.map((e) => e.queryParameters['offset']), ['30', '60']);
  });

  testWidgets('stops auto loading after a bounded number of pages', (
    tester,
  ) async {
    final requests = _fakeNextPages(lastOffset: 1 << 30);

    await _pumpList(
      tester,
      LightingList(source: _firstPageSource(), filter: _onlyUgoira),
    );

    expect(requests.length, 10);
  });
}
