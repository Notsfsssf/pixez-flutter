import 'package:equatable/equatable.dart';
import 'package:pixez/models/user_detail.dart';

abstract class UserState extends Equatable {
  const UserState();
}

class InitialUserState extends UserState {
  @override
  List<Object> get props => [];
}
class UserDataState extends UserState {
  final UserDetail userDetail;

  UserDataState(this.userDetail);

  @override
  // TODO: implement props
  List<Object> get props => [userDetail];
}

class ShowSheetState extends UserState {
  final DateTime dataTime;

  ShowSheetState(this.dataTime);

  @override
  // TODO: implement props
  List<Object> get props => [dataTime];
}