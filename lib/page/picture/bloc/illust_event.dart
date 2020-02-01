import 'package:meta/meta.dart';

@immutable
abstract class IllustEvent {}
class FetchIllustDetailEvent extends IllustEvent{

}
class FollowUserIllustEvent extends IllustEvent{

}