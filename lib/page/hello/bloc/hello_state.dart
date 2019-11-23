import 'package:equatable/equatable.dart';

abstract class HelloState extends Equatable {
  const HelloState();
}

class InitialHelloState extends HelloState {
  @override
  List<Object> get props => [];
}
class HasUserState extends HelloState{
  @override
  // TODO: implement props
  List<Object> get props => null;
}
class NoneUserState extends HelloState{
  @override
  // TODO: implement props
  List<Object> get props => null;
}