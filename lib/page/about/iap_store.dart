import 'dart:async';
import 'dart:core';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'package:mobx/mobx.dart';
import 'package:pixez/er/lprinter.dart';
part 'iap_store.g.dart';

class IAPStore = _IAPStoreBase with _$IAPStore;

abstract class _IAPStoreBase with Store {
  final List<String> _productLists = ['support', 'support1'];
  ObservableList<IAPItem> items = ObservableList();

  dispose() {
    _purchaseErrorSubscription?.cancel();
    _purchaseUpdatedSubscription?.cancel();
  }

  StreamSubscription _purchaseUpdatedSubscription;
  StreamSubscription _purchaseErrorSubscription;

  Future<void> initPlatformState() async {
    var result = await FlutterInappPurchase.instance.initConnection;
    print('result: $result');
    try {
      List<IAPItem> msg = await FlutterInappPurchase.instance
          .getProducts(['support', 'support1']);
      msg.forEach((element) {});
    } catch (err) {
      print('consumeAllItems error: $err');
    }

    _purchaseUpdatedSubscription =
        FlutterInappPurchase.purchaseUpdated.listen((productItem) async {
      print('purchase-updated: $productItem');
      if (productItem.transactionStateIOS == TransactionState.purchased) {
        await FlutterInappPurchase.instance.finishTransaction(productItem);
        BotToast.showNotification(title: (_) => Text('Thanks!'));
      }
    });

    _purchaseErrorSubscription =
        FlutterInappPurchase.purchaseError.listen((purchaseError) {
      print('purchase-error: $purchaseError');
    });
  }

  @action
  Future<void> initAndroidIap() async {
    var result = await FlutterInappPurchase.instance.initConnection;
    print('result: $result');
    try {
      String msg = await FlutterInappPurchase.instance.consumeAllItems;
      print('consumeAllItems: $msg');
    } catch (err) {
      print('consumeAllItems error: $err');
    }
    try {
      var itemx =
          await FlutterInappPurchase.instance.getProducts(_productLists);
      items.clear();
      items.addAll(itemx);
      LPrinter.d(items);
    } catch (err) {
      print('items error: $err');
    }
    _purchaseUpdatedSubscription =
        FlutterInappPurchase.purchaseUpdated.listen((productItem) {
      print('purchase-updated: $productItem');
      if (productItem.purchaseStateAndroid == 1) {
        if (!productItem.isAcknowledgedAndroid) {
          FlutterInappPurchase.instance.acknowledgePurchaseAndroid(
            productItem.purchaseToken,
          );
        }
        print('purchase-acknowledgePurchaseAndroid: ok');
        BotToast.showText(text: 'thanks');
      }
    });

    _purchaseErrorSubscription =
        FlutterInappPurchase.purchaseError.listen((purchaseError) {
      print('purchase-error: $purchaseError');
    });
  }
}
