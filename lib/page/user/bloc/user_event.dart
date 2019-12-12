import 'package:equatable/equatable.dart';
import 'package:pixez/models/user_detail.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();
}
class FetchEvent extends UserEvent {
  final int id;

  FetchEvent(this.id);

  @override
  // TODO: implement props
  List<Object> get props => [id];
}

class ShowSheetEvent extends UserEvent {
  @override
  List<Object> get props => [];
}

class ChoiceRestrictEvent extends UserEvent {
  final String restrict;

  final UserDetail userDetail;

  ChoiceRestrictEvent(this.restrict, this.userDetail);

  @override
  // TODO: implement props
  List<Object> get props => [restrict, userDetail];
}