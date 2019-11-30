import 'package:equatable/equatable.dart';
import 'package:pixez/models/trend_tags.dart';

abstract class TrendTagsState extends Equatable {
  const TrendTagsState();
}

class InitialTrendTagsState extends TrendTagsState {
  @override
  List<Object> get props => [];
}
class TrendTagDataState extends TrendTagsState{
  final TrendingTag trendingTag;

  TrendTagDataState(this.trendingTag);
  @override
  // TODO: implement props
  List<Object> get props => [trendingTag];

}