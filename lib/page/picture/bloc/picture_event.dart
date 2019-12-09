import 'package:equatable/equatable.dart';
import 'package:pixez/models/illust.dart';

abstract class PictureEvent extends Equatable {
  const PictureEvent();
}
class StarEvent extends PictureEvent{
  final Illusts illusts;
  StarEvent(this.illusts);
  @override
  List<Object> get props => [illusts];

}
class UnStarEvent extends PictureEvent{
    final Illusts illusts;
  UnStarEvent(this.illusts);
  @override
  List<Object> get props =>[illusts];
  
}
class SaveImageEvent extends PictureEvent{
  final Illusts illusts;
  final int index;

  SaveImageEvent(this.illusts, this.index);
  

  @override
  List<Object> get props =>[illusts,index];
}