import 'package:meta/meta.dart';
import 'package:pixez/models/spotlight_response.dart';

@immutable
abstract class SpotlightState {}

class InitialSpotlightState extends SpotlightState {}

class DataSpotlight extends SpotlightState {
final List<SpotlightArticle> articles;
final String nextUrl;
  DataSpotlight( this.articles, this.nextUrl);
}
