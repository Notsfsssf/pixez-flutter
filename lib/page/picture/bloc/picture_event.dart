import 'package:equatable/equatable.dart';
import 'package:pixez/models/illust.dart';

abstract class PictureEvent extends Equatable {
  const PictureEvent();
}

class StarPictureEvent extends PictureEvent {
  final Illusts illusts;
  final String restrict;
  final List<String> tags;

  StarPictureEvent(this.illusts, this.restrict, this.tags);

  @override
  List<Object> get props => [illusts];
}

class UnStarPictureEvent extends PictureEvent {
  final Illusts illusts;

  UnStarPictureEvent(this.illusts);

  @override
  List<Object> get props => [illusts];
}
