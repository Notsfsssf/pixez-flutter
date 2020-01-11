import 'package:equatable/equatable.dart';
import 'package:pixez/models/illust.dart';

abstract class RecomState extends Equatable {
  const RecomState();
}

class InitialRecomState extends RecomState {
  var illusts;
  @override
  List<Object> get props => [illusts];
}

class DataRecomState extends RecomState {
  final List<Illusts> illusts;
  final String nextUrl;
  DataRecomState(this.illusts, this.nextUrl);
  @override
  List<Object> get props => [illusts, nextUrl];
}
class FailRecomState extends RecomState{
  @override
  List<Object> get props => [];
}
class LoadMoreSuccessState extends RecomState {
  @override
  List<Object> get props => [];
}
