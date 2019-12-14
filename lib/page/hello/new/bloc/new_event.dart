import 'package:meta/meta.dart';

@immutable
abstract class NewEvent {}

class  RestrictEvent extends NewEvent {
  final String newRestrict,bookRestrict,painterRestrict;

  RestrictEvent(this.newRestrict, this.bookRestrict, this.painterRestrict);

}
class NewInitalEvent extends NewEvent{
  final String newRestrict,bookRestrict,painterRestrict;

  NewInitalEvent(this.newRestrict, this.bookRestrict, this.painterRestrict);
}