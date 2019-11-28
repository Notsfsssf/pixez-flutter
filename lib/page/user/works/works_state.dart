import 'package:equatable/equatable.dart';
import 'package:pixez/models/illust.dart';

abstract class WorksState extends Equatable {
  const WorksState();
}

class InitialWorksState extends WorksState {
  @override
  List<Object> get props => [];
}

class DataWorksState extends WorksState {
  final List<Illusts> illusts;
  final String nextUrl;

  DataWorksState(this.illusts, this.nextUrl);

  @override
  // TODO: implement props
  List<Object> get props => [illusts, nextUrl];
}

class LoadMoreSuccessState extends WorksState {
  @override
  // TODO: implement props
  List<Object> get props => null;
}
