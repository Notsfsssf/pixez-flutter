/*
 * Copyright (C) 2020. by perol_notsf, All rights reserved
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program. If not, see <http://www.gnu.org/licenses/>.
 *
 */

import 'dart:async';
import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'package:pixez/generated/l10n.dart';
import 'package:pixez/page/about/bloc/about_bloc.dart';
import 'package:pixez/page/about/bloc/bloc.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatefulWidget {
  @override
  _AboutPageState createState() => _AboutPageState();
}



class _AboutPageState extends State<AboutPage> {
  StreamSubscription _purchaseUpdatedSubscription;
  StreamSubscription _purchaseErrorSubscription;
  final List<String> _productLists = ['support', 'support1'];
  List<IAPItem> _items = [];

  Future<void> initAndroidIap() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await FlutterInappPurchase.instance.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }
    // prepare
    var result = await FlutterInappPurchase.instance.initConnection;
    print('result: $result');

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
    // refresh items for android
    try {
      String msg = await FlutterInappPurchase.instance.consumeAllItems;
      print('consumeAllItems: $msg');
    } catch (err) {
      print('consumeAllItems error: $err');
    }
    try {
      var itemx =
          await FlutterInappPurchase.instance.getProducts(_productLists);
      setState(() {
        _items = itemx;
      });
    } catch (err) {
      print('consumeAllItems error: $err');
    }
    _purchaseUpdatedSubscription =
        FlutterInappPurchase.purchaseUpdated.listen((productItem) {
      print('purchase-updated: $productItem');
      if (productItem.purchaseStateAndroid == 1) {
        if (!productItem.isAcknowledgedAndroid) {
          FlutterInappPurchase.instance.acknowledgePurchaseAndroid(
              productItem.purchaseToken,
              developerPayload: productItem.developerPayloadAndroid);
        }
        print('purchase-acknowledgePurchaseAndroid: ok');
        BotToast.showText(text: I18n.of.(context).Tanks);
      }
    });

    _purchaseErrorSubscription =
        FlutterInappPurchase.purchaseError.listen((purchaseError) {
      print('purchase-error: $purchaseError');
    });
  }

  @override
  void initState() {
    super.initState();
    if (Platform.isIOS) initPlatformState();
    if (Platform.isAndroid) initAndroidIap();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // prepare
    var result = await FlutterInappPurchase.instance.initConnection;
    print('result: $result');
    List<IAPItem> iaps =
        await FlutterInappPurchase.instance.getProducts(_productLists);
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    // refresh items for android
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
        BotToast.showNotification(title: (_) => Text(I18n.of.(context).Thanks));
      }
    });

    _purchaseErrorSubscription =
        FlutterInappPurchase.purchaseError.listen((purchaseError) {
      print('purchase-error: $purchaseError');
    });
  }

  @override
  void dispose() {
    _purchaseErrorSubscription?.cancel();
    _purchaseUpdatedSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AboutBloc>(
      child: Scaffold(
        appBar: AppBar(
          title: Text(I18n
              .of(context)
              .About),
          actions: <Widget>[],
        ),
        body: _buildInfo(context),
      ),
      create: (BuildContext context) => AboutBloc(),
    );
  }

  Widget _buildInfo(BuildContext context) {
    return ListView(
      children: <Widget>[
        ListTile(
          leading: CircleAvatar(
            backgroundImage: AssetImage('assets/images/me.jpg'),
          ),
          title: Text(I18n.of.(context).Authour),
          subtitle: Text(I18n.of.(context).Authour_message),
          onTap: () {
            showModalBottomSheet(
              context: context,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              builder: (BuildContext context) {
                return Container(
                  child: Image.asset(
                    'assets/images/sustain.png',
                    fit: BoxFit.cover,
                  ),
                );
              },
            );
          },
        ),
        ListTile(
          leading: CircleAvatar(
            backgroundImage: AssetImage('assets/images/right_now.jpg'),
          ),
          title: Text(I18n.of.(context).Designer),
          subtitle: Text(I18n.of.(context).Designer_message),
          onTap: () {
            showModalBottomSheet(
              context: context,
              builder: (BuildContext context) {
                return Container(
                  height: 200.0,
                  color: Color(0xfff1f1f1),
                  child: Center(
                    child: Text(I18n.of(context).Designer_intro),
                  ),
                );
              },
            );
          },
        ),
        ListTile(
          leading: Icon(Icons.rate_review),
          title: Text(I18n.of.(context).Rate),
          subtitle: Text(I18n.of.(context).Rate_message),
          onTap: () async {
            if (Platform.isIOS) {
              var url = 'https://apps.apple.com/cn/app/pixez/id1494435126';
              if (await canLaunch(url)) {
                await launch(url);
              } else {}
            }
          },
        ),
        Visibility(
          visible: false,
          child: ListTile(
              leading: Icon(Icons.home),
              title: Text(I18n.of.(context).Page),
              subtitle: Text(I18n.of.(context).Page_message),
              onTap: () async {
                var url = I18n.of.(context).Page_url;
                if (await canLaunch(url)) {
                  await launch(url);
                } else {}
              }),
        ),
        ListTile(
          leading: Icon(Icons.email),
          title: Text(I18n
              .of(context)
              .FeedBack),
          subtitle: SelectableText(I18n.of.(context).FeedBack_message),
        ),
        ListTile(
          leading: Icon(Icons.stars),
          title: Text(I18n
              .of(context)
              .Support),
          subtitle: SelectableText(I18n.of.(context).Support_message)'),
        ),
        ListTile(
          leading: Icon(Icons.favorite),
          title: Text(I18n
              .of(context)
              .Thanks),
          subtitle: Text(I18n.of.(context).Thanks_message),
        ),
        ListTile(
          leading: Icon(Icons.share),
          title: Text(I18n
              .of(context)
              .Share),
          subtitle: Text(I18n
              .of(context)
              .Share_this_app_link),
          onTap: () {
            if (Platform.isIOS) {
              Share.share('https://apps.apple.com/cn/app/pixez/id1494435126');
            }
          },
        ),
        ...(Platform.isAndroid && _items.isNotEmpty)
            ? _items
            .map((IAPItem iapitem) =>
            Card(
              child: ListTile(
                subtitle: Text(I18n.of(context).Donate_message),
                title: Text(I18n.of(context).Donate),
                trailing: Text(iapitem.price),
                onTap: () async {
                  BotToast.showText(text: I18n.of.(context).Donate_toast);
                  await FlutterInappPurchase.instance
                      .requestPurchase(iapitem.productId);
                },
              ),
            ))
            .toList()
            : [],
        ...(Platform.isIOS)
            ? [
          Card(
            child: ListTile(
              subtitle: Text(I18n.of(context).Donate_message),
              title: Text(I18n.of(context).Donate),
              trailing: Text(I18n.of(context).Price),
              onTap: () async {
                BotToast.showText(text: I18n.of.(context).Donate_toast);
                List<PurchasedItem> items = await FlutterInappPurchase
                    .instance
                    .getPendingTransactionsIOS();
                for (var i in items) {
                  await FlutterInappPurchase.instance
                      .finishTransaction(i);
                }
                await FlutterInappPurchase.instance
                    .requestPurchase('support');
              },
            ),
          ),
          Card(
            child: ListTile(
              subtitle: Text(I18n.of.(context).Donate_message),
              title: Text(I18n.of(context).Donate),
              trailing: Text(I18n.of.(context).Donate_price),
              onTap: () async {
                BotToast.showText(text: I18n.of.(context).Donate_toast);

                List<PurchasedItem> items = await FlutterInappPurchase
                    .instance
                    .getPendingTransactionsIOS();
                for (var i in items) {
                  await FlutterInappPurchase.instance
                      .finishTransaction(i);
                }
                await FlutterInappPurchase.instance
                    .requestPurchase('support1');
              },
            ),
          )
        ]
            : [],
      ],
    );
  }
}
