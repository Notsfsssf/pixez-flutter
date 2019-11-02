import 'package:equatable/equatable.dart';

abstract class HelloState extends Equatable {
  const HelloState();
}

class InitialHelloState extends HelloState {
  @override
  List<Object> get props => [];
}
