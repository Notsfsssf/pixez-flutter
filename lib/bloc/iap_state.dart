import 'package:flutter_inapp_purchase/modules.dart';
import 'package:meta/meta.dart';

@immutable
abstract class IapState {}

class InitialIapState extends IapState {}

class DataIapState extends IapState {
  List<IAPItem> products;
  List<PurchasedItem> items;
  DataIapState(this.products, this.items);
}

class ThanksState extends IapState {}
