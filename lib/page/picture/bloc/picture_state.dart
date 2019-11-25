import 'package:equatable/equatable.dart';
import 'package:pixez/models/illust.dart';

abstract class PictureState extends Equatable {
  const PictureState();
}

class InitialPictureState extends PictureState {
  @override
  List<Object> get props => [];
}
class DataState extends PictureState{
  final Illusts illusts;
  const DataState(this.illusts);
  @override
  // TODO: implement props
  List<Object> get props =>[illusts];

}