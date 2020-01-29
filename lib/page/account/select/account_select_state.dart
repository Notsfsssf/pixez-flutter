import 'package:meta/meta.dart';
import 'package:pixez/models/account.dart';

@immutable
abstract class AccountSelectState {}

class InitialAccountSelectState extends AccountSelectState {}

class AllAccountSelectState extends AccountSelectState {
  List<AccountPersist> accounts;
  int selectNum;

  AllAccountSelectState(this.accounts, this.selectNum);
}

class SelectState extends AccountSelectState {}
