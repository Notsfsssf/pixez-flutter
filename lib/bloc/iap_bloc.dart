import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'package:flutter_inapp_purchase/modules.dart';
import './bloc.dart';

class IapBloc extends Bloc<IapEvent, IapState> {
  @override
  IapState get initialState => InitialIapState();

  @override
  Stream<IapState> mapEventToState(
    IapEvent event,
  ) async* {
    if (event is InitialEvent) {
      List<PurchasedItem> items =
          await FlutterInappPurchase.instance.getPurchaseHistory();
      for (var item in items) {
        print('${item.toString()}');
      }
    }
    if (event is FetchIapEvent) {
      List<IAPItem> items =
          await FlutterInappPurchase.instance.getProducts(['all']);
      yield DataIapState(items);
    }
    if (event is MakeIapEvent) {

    }
  }
}
