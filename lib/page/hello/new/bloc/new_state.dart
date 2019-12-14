import 'package:meta/meta.dart';

@immutable
abstract class NewState {}

class InitialNewState extends NewState {

}
class NewDataRestrictState extends NewState{
  final String newRestrict,bookRestrict,painterRestrict;

  NewDataRestrictState(this.newRestrict, this.bookRestrict, this.painterRestrict);
}

