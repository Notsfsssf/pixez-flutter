import 'package:equatable/equatable.dart';
import 'package:pixez/models/user_detail.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();
}
class FetchEvent extends UserEvent {
  final int id;

  FetchEvent(this.id);

  @override
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
  List<Object> get props => [restrict, userDetail];
}
class FollowUserEvent extends UserEvent{
  final UserDetail userDetail;
  final String restrict,followRestrict;
  FollowUserEvent(this.userDetail, this.restrict,this.followRestrict);
  @override
  List<Object> get props => [userDetail,restrict,followRestrict];

}