import 'package:equatable/equatable.dart';
import 'package:pixez/models/illust.dart';

abstract class PictureEvent extends Equatable {
  const PictureEvent();
}
class StarEvent extends PictureEvent{
  final Illusts illusts;
  final String restrict;
  final List<String> tags;
  StarEvent(this.illusts, this.restrict, this.tags);
  @override
  List<Object> get props => [illusts];

}
class UnStarEvent extends PictureEvent{
    final Illusts illusts;
  UnStarEvent(this.illusts);
  @override
  List<Object> get props =>[illusts];
  
}

