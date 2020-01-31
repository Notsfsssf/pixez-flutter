import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'package:meta/meta.dart';

@immutable
abstract class IapEvent {}

class FetchIapEvent extends IapEvent {}
class InitialEvent extends IapEvent{

}
class MakeIapEvent extends IapEvent {
MakeIapEvent();
}
class ThanksEvent extends IapEvent{}
