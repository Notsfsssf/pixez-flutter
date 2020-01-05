import 'package:meta/meta.dart';

@immutable
abstract class SoupEvent {}

class FetchSoupEvent extends SoupEvent {
  final String url;

  FetchSoupEvent(this.url);
}
