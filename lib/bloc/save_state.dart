import 'package:meta/meta.dart';
import 'package:pixez/bloc/bloc.dart';

@immutable
abstract class SaveState {}

class InitialSaveState extends SaveState {}
class SaveSuccesState extends SaveState {
  final bool isNotSave;
  SaveSuccesState(this.isNotSave);

}
class SaveChoiceSuccesState extends SaveState {
  final bool isNotSave;
  SaveChoiceSuccesState(this.isNotSave);

}
class SaveAlreadyGoingOnState extends SaveState{}
class SaveProgressSate extends  SaveState{
  
}