import 'package:pixez/models/illust.dart';

abstract class WorksState {
  const WorksState();
}

class InitialWorksState extends WorksState {}

class DataWorksState extends WorksState {
  final List<Illusts> illusts;
  final String nextUrl;

  DataWorksState(this.illusts, this.nextUrl);

  @override
  List<Object> get props => [illusts, nextUrl];
}

class FailWorkState extends WorksState {}

class LoadMoreSuccessState extends WorksState {}

class LoadMoreFailState extends WorksState {}

class LoadMoreEndState extends WorksState {}