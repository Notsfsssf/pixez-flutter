import 'package:meta/meta.dart';
import 'package:pixez/models/account.dart';

@immutable
abstract class AccountEvent {}

class FetchDataBaseEvent extends AccountEvent {

}
class DeleteAllAccountEvent extends AccountEvent{}
class UpdateAccountEvent extends AccountEvent{
  final AccountPersist accountPersist;

  UpdateAccountEvent(this.accountPersist);
}