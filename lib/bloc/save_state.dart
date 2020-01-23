import 'package:meta/meta.dart';
import 'package:pixez/models/illust.dart';

@immutable
abstract class SaveState {}

class InitialSaveState extends SaveState {}
class SaveAlreadyGoingOnState extends SaveState {}
class SaveSuccesState extends SaveState {
  final bool isNotSave;

  SaveSuccesState(this.isNotSave);
}

class SaveStartState extends SaveState {}

class SaveChoiceSuccesState extends SaveState {
  final bool isNotSave;

  SaveChoiceSuccesState(this.isNotSave);
}

class SaveProgressSate extends SaveState {
  final Map<String, ProgressNum> progressMaps;

  SaveProgressSate(this.progressMaps);
}

class ProgressNum {
  final int min, max;
  final Illusts illusts;
  ProgressNum(this.min, this.max, this.illusts);
}
