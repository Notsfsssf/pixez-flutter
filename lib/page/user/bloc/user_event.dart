import 'package:equatable/equatable.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();
}
class FetchEvent extends UserEvent{
  final int id;

  FetchEvent(this.id);
  @override
  // TODO: implement props
  List<Object> get props => [id];

}