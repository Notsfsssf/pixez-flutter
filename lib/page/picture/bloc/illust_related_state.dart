import 'package:meta/meta.dart';
import 'package:pixez/models/recommend.dart';

@immutable
abstract class IllustRelatedState {}

class InitialIllustRelatedState extends IllustRelatedState {}

class DataIllustRelatedState extends IllustRelatedState {
  final Recommend recommend;

  DataIllustRelatedState(this.recommend);
}
