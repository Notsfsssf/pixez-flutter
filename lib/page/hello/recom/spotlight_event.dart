import 'package:meta/meta.dart';

@immutable
abstract class SpotlightEvent {}

class FetchSpotlightEvent extends SpotlightEvent {}
