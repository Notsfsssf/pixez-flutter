import 'package:meta/meta.dart';

@immutable
abstract class AccountEvent {}

class FetchDataBaseEvent extends AccountEvent {

}
class DeleteAllAccountEvent extends AccountEvent{}
