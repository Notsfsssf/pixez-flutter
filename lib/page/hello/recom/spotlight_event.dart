import 'package:meta/meta.dart';
import 'package:pixez/models/spotlight_response.dart';

@immutable
abstract class SpotlightEvent {}

class FetchSpotlightEvent extends SpotlightEvent {}
class LoadMoreSpolightEvent extends SpotlightEvent{
  final List<SpotlightArticle> articles;
  final String nextUrl;

  LoadMoreSpolightEvent(
    this.articles,
    this.nextUrl,
  );
}