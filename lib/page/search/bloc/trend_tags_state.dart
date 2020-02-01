import 'package:equatable/equatable.dart';
import 'package:pixez/models/trend_tags.dart';

abstract class TrendTagsState {
  const TrendTagsState();
}

class InitialTrendTagsState extends TrendTagsState {

}
class TrendTagDataState extends TrendTagsState{
  final TrendingTag trendingTag;

  TrendTagDataState(this.trendingTag);


}