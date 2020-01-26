import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'package:meta/meta.dart';

@immutable
abstract class IapEvent {}

class FetchIapEvent extends IapEvent {}
class InitialEvent extends IapEvent{

}
class MakeIapEvent extends IapEvent {
  final IAPItem productDetails;

  MakeIapEvent(this.productDetails);
}
class ThanksEvent extends IapEvent{}
