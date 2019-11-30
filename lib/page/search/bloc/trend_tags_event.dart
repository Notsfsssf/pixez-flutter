import 'package:equatable/equatable.dart';

abstract class TrendTagsEvent extends Equatable {
  const TrendTagsEvent();
}
class FetchEvent extends TrendTagsEvent{
  
  @override
  // TODO: implement props
  List<Object> get props => null;
}