import 'package:meta/meta.dart';
import 'package:pixez/bloc/bloc.dart';

@immutable
abstract class HistoryPersistState {}
  
class InitialHistoryPersistState extends HistoryPersistState {}
class DataHistoryPersistState extends HistoryPersistState{
  
}