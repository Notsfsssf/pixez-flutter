import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'package:flutter_inapp_purchase/modules.dart';
import './bloc.dart';

class IapBloc extends Bloc<IapEvent, IapState> {
  @override
  IapState get initialState => InitialIapState();
  StreamSubscription _purchaseUpdatedSubscription;
  StreamSubscription _purchaseErrorSubscription;
  @override
  Stream<IapState> mapEventToState(
    IapEvent event,
  ) async* {
    if (event is ThanksEvent) {
      yield ThanksState();
    }
    if (event is InitialEvent) {
      var result = await FlutterInappPurchase.instance.initConnection;

      _purchaseUpdatedSubscription =
          FlutterInappPurchase.purchaseUpdated.listen((productItem) async {
        print('purchase-updated: $productItem');
        var result =
            await FlutterInappPurchase.instance.finishTransaction(productItem);
        try {
          Map<String, dynamic> resultMap = json.decode(result);
          if (resultMap['message'] == 'finished') {
            add(ThanksEvent());
          }
        } catch (e) {}
      });
      _purchaseErrorSubscription =
          FlutterInappPurchase.purchaseError.listen((purchaseError) {
        print('purchase-error: $purchaseError');
      });
    }
    if (event is FetchIapEvent) {
      List<IAPItem> items =
          await FlutterInappPurchase.instance.getProducts(['support']);
      yield DataIapState(items, []);
    }
    if (event is MakeIapEvent) {
      List<PurchasedItem> items =
          await FlutterInappPurchase.instance.getPendingTransactionsIOS();
      for (var i in items) {
        await FlutterInappPurchase.instance.finishTransaction(i);
      }
      FlutterInappPurchase.instance
          .requestPurchase(event.productDetails.productId);
      add(FetchIapEvent());
    }
  }
}
