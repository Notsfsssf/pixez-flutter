import 'package:meta/meta.dart';
import 'package:pixez/models/illust_persist.dart';

@immutable
abstract class HistoryPersistState {}

class InitialHistoryPersistState extends HistoryPersistState {}

class DataHistoryPersistState extends HistoryPersistState {
  final List<IllustPersist> illusts;

  DataHistoryPersistState(this.illusts);
}

class InsertSuccessState extends HistoryPersistState {}

class DeleteSuccessState extends HistoryPersistState {}