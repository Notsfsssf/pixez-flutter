import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:pixez/bloc/iap_bloc.dart';
import 'package:pixez/bloc/iap_event.dart';
import 'package:pixez/bloc/iap_state.dart';
import 'package:pixez/generated/i18n.dart';
import 'package:pixez/page/about/bloc/about_bloc.dart';
import 'package:pixez/page/about/bloc/bloc.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatefulWidget {
  @override
  _AboutPageState createState() => _AboutPageState();
}

void deliverProduct(PurchaseDetails purchaseDetails) async {
  print("deliverProduct");
  await InAppPurchaseConnection.instance.completePurchase(purchaseDetails);
}

class _AboutPageState extends State<AboutPage> {
  StreamSubscription _purchaseUpdatedSubscription;
  StreamSubscription _purchaseErrorSubscription;
  final List<String> _productLists = ['support', 'support1'];

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

// Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // prepare
    var result = await FlutterInappPurchase.instance.initConnection;
    print('result: $result');
       List<IAPItem> iaps=   await  FlutterInappPurchase.instance.getProducts(_productLists);
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    // refresh items for android
    try {
      var msg = await FlutterInappPurchase.instance.getPendingTransactionsIOS();
      msg.forEach((f) {
        FlutterInappPurchase.instance.finishTransaction(f);
      });
    } catch (err) {
      print('consumeAllItems error: $err');
    }

    _purchaseUpdatedSubscription =
        FlutterInappPurchase.purchaseUpdated.listen((productItem) async {
      print('purchase-updated: $productItem');
      if(productItem.transactionStateIOS==TransactionState.purchased){
          await FlutterInappPurchase.instance.finishTransaction(productItem);
         BotToast.showNotification(title: (_) => Text('Thanks!'));
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
    BlocProvider.of<IapBloc>(context)..add(FetchIapEvent());
    return BlocProvider<AboutBloc>(
      child: Scaffold(
        appBar: AppBar(
          title: Text(I18n.of(context).About),
          actions: <Widget>[
            // IconButton(
            //   icon: Icon(Icons.email),
            //   onPressed: () {

            //     showCupertinoDialog(
            //       context: context,
            //       builder: (BuildContext context) {
            //         return CupertinoPopupSurface(
            //       child: Text('data'),

            //         );
            //       },
            //     );
            //   },
            // )
          ],
        ),
        body: _buildInfo(context),
      ),
      create: (BuildContext context) => AboutBloc(),
    );
  }

  Widget _buildInfo(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<IapBloc, IapState>(listener: (context, state) {
          if (state is ThanksState) {
            BotToast.showNotification(title: (_) => Text('Thanks!'));
          }
        }),
      ],
      child: BlocBuilder<AboutBloc, AboutState>(builder: (context, snapshot) {
        return ListView(
          children: <Widget>[
            ListTile(
              leading: CircleAvatar(
                backgroundImage: AssetImage('assets/images/me.jpg'),
              ),
              title: Text('Perol_Notsfsssf'),
              subtitle: Text('使用flutter开发'),
              onTap: (){
                
              },
            ),
            ListTile(
              leading: Icon(Icons.rate_review),
              title: Text('如果你觉得PixEz还不错'),
              subtitle: Text('好评鼓励一下吧！'),
              onTap: () async {
                var url = 'https://apps.apple.com/cn/app/pixez/id1494435126';
                if (await canLaunch(url)) {
                  await launch(url);
                } else {}
              },
            ),
            Visibility(
              visible: false,
              child: ListTile(
                  leading: Icon(Icons.home),
                  title: Text('GitHub Page'),
                  subtitle: Text('https://github.com/Notsfsssf'),
                  onTap: () async {
                    var url = 'https://github.com/Notsfsssf';
                    if (await canLaunch(url)) {
                      await launch(url);
                    } else {}
                  }),
            ),
            ListTile(
              leading: Icon(Icons.email),
              title: Text(I18n.of(context).FeedBack),
              subtitle: SelectableText('PxezFeedBack@outlook.com'),
            ),
            ListTile(
              leading: Icon(Icons.stars),
              title: Text(I18n.of(context).Support),
              subtitle: SelectableText('欢迎反馈建议或共同开发:)'),
            ),
            ListTile(
              leading: Icon(Icons.favorite),
              title: Text(I18n.of(context).Thanks),
              subtitle: Text('感谢帮助我测试的弹幕委员会群友们'),
            ),
            ListTile(
              leading: Icon(Icons.share),
              title: Text(I18n.of(context).Share),
              subtitle: Text(I18n.of(context).Share_this_app_link),
              onTap: () {
                Share.share('https://apps.apple.com/cn/app/pixez/id1494435126');
              },
            ),
            Card(
              child: ListTile(
                subtitle: Text('如果你觉得这个应用还不错，支持一下开发者吧!'),
                title: Text('支持开发者工作'),
                trailing: Text('12￥'),
                onTap: () async {
                  BotToast.showText(text: 'try to Purchase');
                               List<PurchasedItem> items = await FlutterInappPurchase
                      .instance
                      .getPendingTransactionsIOS();
                  for (var i in items) {
                    await FlutterInappPurchase.instance.finishTransaction(i);
                  }
                 await FlutterInappPurchase.instance.requestPurchase('support');
                  BlocProvider.of<IapBloc>(context)
                      .add(MakeIapEvent('support'));
                },
              ),
            ),
            Card(
              child: ListTile(
                subtitle: Text('如果你觉得这个应用非常不错，支持一下开发者吧！'),
                title: Text('支持开发者工作'),
                trailing: Text('25￥'),
                onTap: () async {
                  BotToast.showText(text: 'try to Purchase');
      
                  List<PurchasedItem> items = await FlutterInappPurchase
                      .instance
                      .getPendingTransactionsIOS();
                  for (var i in items) {
                    await FlutterInappPurchase.instance.finishTransaction(i);
                  }
                 await FlutterInappPurchase.instance.requestPurchase('support1');
                  BlocProvider.of<IapBloc>(context)
                      .add(MakeIapEvent('support1'));
                },
              ),
            )
          ],
        );
      }),
    );
  }
}
