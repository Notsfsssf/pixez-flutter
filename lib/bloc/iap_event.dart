import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:meta/meta.dart';

@immutable
abstract class IapEvent {}

class FetchIapEvent extends IapEvent {}
class InitialEvent extends IapEvent{
  
}
class MakeIapEvent extends IapEvent {
  final ProductDetails productDetails;

  MakeIapEvent(this.productDetails);
}
