import 'package:flutter_test/flutter_test.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/ban_tag.dart';
import 'package:pixez/models/illust.dart';
import 'package:pixez/models/trend_tags.dart';
import 'package:pixez/page/search/trend_tags_store.dart';

TrendTags _tag(String name) => TrendTags(
      tag: name,
      translatedName: null,
      illust: TrendTagsIllust(
        id: 1,
        imageUrls: ImageUrls(
          squareMedium: 'https://i.pximg.net/square.jpg',
          medium: 'https://i.pximg.net/medium.jpg',
          large: 'https://i.pximg.net/large.jpg',
        ),
      ),
    );

void main() {
  late TrendTagsStore store;

  setUp(() {
    store = TrendTagsStore();
    store.trendTags.addAll([
      _tag('pixivSakuraEffect'),
      _tag('オリジナル'),
      _tag('落書き'),
    ]);
    muteStore.banTags.clear();
  });

  tearDown(() => muteStore.banTags.clear());

  test('shows every trend tag when nothing is muted', () {
    expect(
      store.visibleTrendTags.map((e) => e.tag),
      ['pixivSakuraEffect', 'オリジナル', '落書き'],
    );
  });

  test('hides trend tags that match a muted tag (#1182)', () {
    muteStore.banTags.add(
      BanTagPersist(name: 'pixivSakuraEffect', translateName: ''),
    );

    expect(
      store.visibleTrendTags.map((e) => e.tag),
      ['オリジナル', '落書き'],
    );
  });

  test('supports regex mute rules', () {
    muteStore.banTags.add(BanTagPersist(name: r"r'^pixiv'", translateName: ''));

    expect(
      store.visibleTrendTags.map((e) => e.tag),
      ['オリジナル', '落書き'],
    );
  });
}
