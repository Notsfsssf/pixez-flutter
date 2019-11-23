import 'package:equatable/equatable.dart';
import 'package:pixez/models/illust.dart';

abstract class RecomState extends Equatable {



  const RecomState();
}

class InitialRecomState extends RecomState {
  var illusts;
  @override
  List<Object> get props => [];
}
class DataRecomState extends RecomState{
  final List<Illusts >illusts;
  DataRecomState(this.illusts);
  @override
  // TODO: implement props
  List<Object> get props => [illusts];

}
