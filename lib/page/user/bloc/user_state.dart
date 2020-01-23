import 'package:pixez/models/user_detail.dart';

abstract class UserState {
  const UserState();
}

class InitialUserState extends UserState {}

class UserDataState extends UserState {
  final UserDetail userDetail;
  final String choiceRestrict;

  const UserDataState(this.userDetail, this.choiceRestrict);

}

class FZFState extends UserState {}

class ShowSheetState extends UserState {
}

class ChoiceRestrictState extends UserState {
  final String choiceRestrict;

  ChoiceRestrictState(this.choiceRestrict);

}
