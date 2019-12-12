import 'package:equatable/equatable.dart';
import 'package:pixez/models/account.dart';

abstract class RouteState extends Equatable {
  const RouteState();
}

class InitialRouteState extends RouteState {
  @override
  List<Object> get props => [];
}

class HasUserState extends RouteState {
  final AccountPersist list;

  HasUserState(this.list);

  @override
  List<Object> get props => [list];
}

class NoneUserState extends RouteState {
  @override
  List<Object> get props => [];
}
