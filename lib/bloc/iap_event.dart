import 'package:flutter_inapp_purchase/modules.dart';
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
