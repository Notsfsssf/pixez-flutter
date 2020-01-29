import 'package:meta/meta.dart';

@immutable
abstract class AccountSelectEvent {}

class FetchAllAccountSelectEvent extends AccountSelectEvent {}

class DeleteAccountSelectEvent extends AccountSelectEvent {
  int id;

  DeleteAccountSelectEvent(this.id);
}

class SelectAccountSelectEvent extends AccountSelectEvent {
  final int num;

  SelectAccountSelectEvent(this.num);
}
