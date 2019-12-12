import 'package:pixez/models/user_detail.dart';

abstract class UserState {
  const UserState();
}

class InitialUserState extends UserState {
  @override
  List<Object> get props => [];
}

class UserDataState extends UserState {
  final UserDetail userDetail;
  final String choiceRestrict;

  const UserDataState(this.userDetail, this.choiceRestrict);

  @override
  List<Object> get props => [userDetail, choiceRestrict];
}

class ShowSheetState extends UserState {
  @override
  List<Object> get props => [];
}

class ChoiceRestrictState extends UserState {
  final String choiceRestrict;

  ChoiceRestrictState(this.choiceRestrict);

  @override
  List<Object> get props => [choiceRestrict];
}
