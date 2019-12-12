import 'package:equatable/equatable.dart';

abstract class RouteEvent extends Equatable {
  const RouteEvent();
}

class FetchDataBaseEvent extends RouteEvent {
  @override
  List<Object> get props => [];
}