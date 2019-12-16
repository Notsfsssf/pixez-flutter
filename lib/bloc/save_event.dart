import 'package:meta/meta.dart';
import 'package:pixez/models/illust.dart';

@immutable
abstract class SaveEvent {}
class SaveImageEvent extends SaveEvent{
  final Illusts illusts;
  final int index;

  SaveImageEvent(this.illusts, this.index);

  @override
  List<Object> get props =>[illusts,index];
}
class SaveChoiceImageEvent extends SaveEvent{
  final Illusts illusts;
  final List<bool> indexs;

  SaveChoiceImageEvent(this.illusts, this.indexs);

  @override
  List<Object> get props =>[illusts,indexs];
}