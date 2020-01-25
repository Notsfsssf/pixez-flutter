import 'dart:async';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import './bloc.dart';

class IapBloc extends Bloc<IapEvent, IapState> {
  @override
  IapState get initialState => InitialIapState();

  @override
  Stream<IapState> mapEventToState(
    IapEvent event,
  ) async* {
    if (event is InitialEvent) {
      StreamSubscription<List<PurchaseDetails>> _subscription;
      final Stream purchaseUpdates =
          InAppPurchaseConnection.instance.purchaseUpdatedStream;
      _subscription = purchaseUpdates.listen((purchaseDetailsList) {
        _handlePurchaseUpdates(purchaseDetailsList);
      }, onDone: () {
        _subscription.cancel();
      }, onError: (error) {
        // handle error here.
        print(error);
      });
      final QueryPurchaseDetailsResponse response =
          await InAppPurchaseConnection.instance.queryPastPurchases();
      if (response.error != null) {
        // Handle the error.
      }
      for (PurchaseDetails purchase in response.pastPurchases) {
        print('sfsdfds'+purchase.status.toString());
        if (Platform.isIOS) {
          // Mark that you've delivered the purchase. Only the App Store requires
          // this final confirmation.
          InAppPurchaseConnection.instance.completePurchase(purchase);
        }
      }
    }
    if (event is FetchIapEvent) {
      final bool available =
          await InAppPurchaseConnection.instance.isAvailable();
      if (available) {}
      const Set<String> _kIds = {'all'};
      final ProductDetailsResponse response =
          await InAppPurchaseConnection.instance.queryProductDetails(_kIds);

      if (!response.notFoundIDs.isEmpty) {
        // Handle the error.
      }
      List<ProductDetails> products = response.productDetails;
      yield DataIapState(products);
    }
    if (event is MakeIapEvent) {
      final ProductDetails productDetails =
          event.productDetails; // Saved earlier from queryPastPurchases().
      final PurchaseParam purchaseParam =
          PurchaseParam(productDetails: productDetails);
      InAppPurchaseConnection.instance
          .buyNonConsumable(purchaseParam: purchaseParam);
    }
  }

  Future<void> _handlePurchaseUpdates(List<PurchaseDetails> purchases) async {
    print('product:==========${purchases.length}');
    if (purchases.isNotEmpty) {
      var purchaseDetails = purchases[0];
      print('${purchaseDetails.status}');
      if (purchaseDetails.pendingCompletePurchase) {
        await InAppPurchaseConnection.instance
            .completePurchase(purchaseDetails);
      }
    }
  }
}
