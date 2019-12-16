import 'package:meta/meta.dart';

@immutable
abstract class SaveState {}

class InitialSaveState extends SaveState {}
class SaveSuccesState extends SaveState {
  final bool isNotSave;
  SaveSuccesState(this.isNotSave);
  @override
  List<Object> get props => [isNotSave];
}
class SaveChoiceSuccesState extends SaveState {
  final bool isNotSave;
  SaveChoiceSuccesState(this.isNotSave);
  @override
  List<Object> get props => [isNotSave];
}