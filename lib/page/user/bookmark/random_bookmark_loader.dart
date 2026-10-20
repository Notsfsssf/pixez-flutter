import 'dart:math';

import 'package:dio/dio.dart';

/// Samples bookmark ID boundaries, not uniform positions in the user's list.
class RandomBookmarkLoader {
  final Future<Response> Function(int? maxBookmarkId) fetch;
  final Random random;
  final Set<int> _seen = {};
  Response? _first;
  int? _upper;
  int _lower = 1;

  RandomBookmarkLoader(this.fetch, {Random? random})
    : random = random ?? Random();

  Future<Response> refresh() async {
    final first = await fetch(null);
    _first = first;
    _seen.clear();
    _lower = 1;
    final next = first.data['next_url'] as String?;
    _upper = next == null
        ? null
        : int.tryParse(
            Uri.parse(next).queryParameters['max_bookmark_id'] ?? '',
          );
    return nextPage(includeFirst: false);
  }

  Future<Response> nextPage({bool includeFirst = true}) async {
    if (_first == null) return refresh();
    Response fallback = _first!;
    // Include the newest page too: its first 29 bookmark IDs are not exposed.
    for (var attempt = 0; attempt < 3; attempt++) {
      final upper = _upper;
      final useFirst =
          upper == null || (includeFirst && random.nextInt(4) == 0);
      final boundary = useFirst
          ? null
          : _lower + (random.nextDouble() * (upper - _lower)).floor();
      final response = useFirst ? _first! : await fetch(boundary);
      final works = List<dynamic>.from(response.data['illusts'] as List);
      if (works.isEmpty) {
        if (boundary != null) _lower = max(_lower, boundary);
        continue;
      }
      fallback = response;
      works.removeWhere((work) => _seen.contains(work['id']));
      if (works.isNotEmpty) return _page(response, works);
      if (upper == null) break;
    }
    // On entry, prefer the known next page over showing the newest page again.
    if (!includeFirst && _upper != null) {
      final response = await fetch(_upper);
      if ((response.data['illusts'] as List).isNotEmpty) fallback = response;
    }
    // Small collections or repeated boundaries must not cause unbounded retries.
    final works = List<dynamic>.from(fallback.data['illusts'] as List);
    final unseen = works.where((work) => !_seen.contains(work['id'])).toList();
    if (unseen.isNotEmpty) return _page(fallback, unseen);
    _seen.clear();
    return _page(fallback, works);
  }

  Response _page(Response response, List<dynamic> works) {
    works.shuffle(random);
    _seen.addAll(works.map((work) => work['id'] as int));
    return Response(
      requestOptions: response.requestOptions,
      statusCode: response.statusCode,
      data: <String, dynamic>{...response.data as Map, 'illusts': works},
    );
  }
}
