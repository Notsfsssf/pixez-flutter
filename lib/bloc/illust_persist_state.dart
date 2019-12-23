import 'package:meta/meta.dart';
import 'package:pixez/models/illust_persist.dart';

@immutable
abstract class IllustPersistState {}
  
class InitialIllustPersistState extends IllustPersistState {}
class DataIllustPersistState extends IllustPersistState {
  final List<IllustPersist> illusts;

  DataIllustPersistState(this.illusts);
}

class InsertSuccessState extends IllustPersistState {}

class DeleteSuccessState extends IllustPersistState {}