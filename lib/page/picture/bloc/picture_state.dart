import 'package:equatable/equatable.dart';
import 'package:pixez/models/illust.dart';

abstract class PictureState extends Equatable {
  const PictureState();
}

class InitialPictureState extends PictureState {
  @override
  List<Object> get props => [];
}

class DataState extends PictureState {
  final Illusts illusts;
  const DataState(this.illusts);
  @override
  List<Object> get props => [illusts];
}

class SaveSuccesState extends PictureState {
  final bool isNotSave;
  SaveSuccesState(this.isNotSave);
  @override
  List<Object> get props => [isNotSave];
}

class BookMarkState extends PictureState {
  final bool isBookMark;

  BookMarkState(this.isBookMark);
  @override
  List<Object> get props => [isBookMark];
}
