import 'package:meta/meta.dart';
import 'package:pixez/models/illust.dart';

@immutable
abstract class IllustRelatedEvent {}
class FetchRelatedEvent extends IllustRelatedEvent{
  final Illusts illusts;

  FetchRelatedEvent(this.illusts);
  @override
  List<Object> get props => [illusts];

}