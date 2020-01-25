import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:meta/meta.dart';

@immutable
abstract class IapState {}
  
class InitialIapState extends IapState {}
class DataIapState extends IapState{
  final List<ProductDetails> products;

  DataIapState(this.products);
}
