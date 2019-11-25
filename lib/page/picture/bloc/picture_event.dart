import 'package:equatable/equatable.dart';
import 'package:pixez/models/illust.dart';

abstract class PictureEvent extends Equatable {
  const PictureEvent();
}
class StarEvent extends PictureEvent{
  final Illusts illusts;
  StarEvent(this.illusts);
  @override
  // TODO: implement props
  List<Object> get props => [illusts];

}
class UnStarEvent extends PictureEvent{
  @override
  // TODO: implement props
  List<Object> get props => null;
  
}