import 'package:meta/meta.dart';

@immutable
abstract class IapEvent {}

class FetchIapEvent extends IapEvent {}
class InitialEvent extends IapEvent{

}
class MakeIapEvent extends IapEvent {
  final String id;
MakeIapEvent(this.id);
}
class ThanksEvent extends IapEvent{}
