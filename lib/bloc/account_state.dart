import 'package:meta/meta.dart';
import 'package:pixez/models/account.dart';

@immutable
abstract class AccountState {}

class InitialAccountState extends AccountState {}

class HasUserState extends AccountState {
  final AccountPersist list;

  HasUserState(this.list);


}

class NoneUserState extends AccountState {

}
