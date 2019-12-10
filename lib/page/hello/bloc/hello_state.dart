import 'package:equatable/equatable.dart';
import 'package:pixez/models/account.dart';

abstract class HelloState extends Equatable {
  const HelloState();
}

class InitialHelloState extends HelloState {
  @override
  List<Object> get props => [];
}
class HasUserState extends HelloState{
  final AccountPersist list;

  HasUserState(this.list);

  @override
  List<Object> get props => [list];
}
class NoneUserState extends HelloState{
  @override
  List<Object> get props => null;
}