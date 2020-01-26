
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'package:meta/meta.dart';

@immutable
abstract class IapState {}
  
class InitialIapState extends IapState {}
class DataIapState extends IapState{
  final List<IAPItem> products;

  DataIapState(this.products);
}
