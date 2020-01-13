import 'package:meta/meta.dart';
import 'package:pixez/models/illust.dart';

@immutable
abstract class LightingEvent {}

class LightingFetch extends LightingEvent {
  final String restrict;

  LightingFetch(this.restrict);
}

class LightingRefresh extends LightingEvent {}

class LightingLoadMore extends LightingEvent {
  final List<Illusts> illusts;
  final String nextUrl;

  LightingLoadMore(
    this.illusts,
    this.nextUrl,
  );
}
