import 'package:equatable/equatable.dart';
import 'package:pixez/models/illust.dart';

abstract class NewIllustState extends Equatable {
  const NewIllustState();
}

class InitialNewIllustState extends NewIllustState {
  @override
  List<Object> get props => [];
}

class DataNewIllustState extends NewIllustState {
  final List<Illusts> illusts;
  final String nextUrl;
  DataNewIllustState(this.illusts, this.nextUrl);
  @override
  // TODO: implement props
  List<Object> get props => [illusts, nextUrl];
}

class LoadMoreSuccessState extends NewIllustState {
  @override
  // TODO: implement props
  List<Object> get props => null;
}
