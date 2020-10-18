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
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'package:pixez/component/new_version_chip.dart';
import 'package:pixez/constants.dart';
import 'package:pixez/generated/l10n.dart';
import 'package:pixez/page/about/thanks_list.dart';
import 'package:pixez/page/about/update_page.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatefulWidget {
  final bool newVersion;

  const AboutPage({Key key, this.newVersion}) : super(key: key);

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
        BotToast.showText(text: 'thanks');
      }
    });

    _purchaseErrorSubscription =
        FlutterInappPurchase.purchaseError.listen((purchaseError) {
      print('purchase-error: $purchaseError');
    });
  }

  bool hasNewVersion;

  @override
  void initState() {
    hasNewVersion = widget.newVersion ?? false;
    super.initState();
    if (Platform.isIOS) initPlatformState();
    // if (Platform.isAndroid) initAndroidIap();
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
    return Scaffold(
      appBar: AppBar(
        title: Text(I18n.of(context).about),
        actions: <Widget>[],
      ),
      body: _buildInfo(context),
    );
  }

  Widget _buildInfo(BuildContext context) {
    return ListView(
      children: <Widget>[
        ListTile(
          leading: CircleAvatar(
            backgroundImage: AssetImage('assets/images/me.jpg'),
          ),
          title: Text('Perol_Notsfsssf'),
          subtitle: Text(I18n.of(context).perol_message),
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
                    'assets/images/liz.png',
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
          title: Text('Right now'),
          subtitle: Text(I18n.of(context).right_now_message),
          onTap: () {
            showModalBottomSheet(
              context: context,
              builder: (BuildContext context) {
                return Container(
                  height: 200.0,
                  child: Center(
                    child: Text("这里空空的，这个设计师显然没有什么话要说"),
                  ),
                );
              },
            );
          },
        ),
        ListTile(
          leading: Icon(Icons.rate_review),
          title: Text(I18n.of(context).rate_title),
          subtitle: Text(I18n.of(context).rate_message),
          onTap: () async {
            if (Platform.isIOS) {
              var url = 'https://apps.apple.com/cn/app/pixez/id1494435126';
              if (await canLaunch(url)) {
                await launch(url);
              } else {}
            }
          },
        ),
        if (Platform.isAndroid) ...[
          ListTile(
            leading: Icon(Icons.device_hub),
            title: Text(I18n
                .of(context)
                .repo_address),
            subtitle: SelectableText('github.com/Notsfsssf/pixez-flutter'),
            trailing: Visibility(
              child: NewVersionChip(),
              visible: hasNewVersion,
            ),
            onTap: () {
              if (!Constants.isGooglePlay)
                showModalBottomSheet(
                    context: context,
                    shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.vertical(top: Radius.circular(16.0))),
                    builder: (_) {
                      return Container(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            ListTile(
                              title: Text('Version ${Constants.tagName}'),
                              subtitle:
                                  Text(I18n.of(context).go_to_project_address),
                              onTap: () {
                                try {
                                  launch(
                                      'https://github.com/Notsfsssf/pixez-flutter');
                                } catch (e) {}
                              },
                              trailing: IconButton(
                                  icon: Icon(Icons.link),
                                  onPressed: () {
                                    try {
                                      launch(
                                          'https://github.com/Notsfsssf/pixez-flutter');
                                    } catch (e) {}
                                  }),
                            ),
                            ListTile(
                              title: Text(I18n.of(context).check_for_updates),
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (_) => UpdatePage()));
                              },
                              trailing: Icon(Icons.update),
                            ),
                            ListTile(
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(
                                    'https://avatars1.githubusercontent.com/u/9017470?s=400&v=4'),
                              ),
                              title: Text('Skimige'),
                              subtitle: Text(I18n.of(context).skimige_message),
                            ),
                          ],
                        ),
                      );
                    });
            },
          )
        ],
        Visibility(
          visible: false,
          child: ListTile(
              leading: Icon(Icons.home),
              title: Text('GitHub Page'),
              subtitle: Text('https://github.com/Notsfsssf'),
              onTap: () async {}),
        ),
        ListTile(
          leading: Icon(Icons.email),
          title: Text(I18n.of(context).feedback),
          subtitle: SelectableText('PxezFeedBack@outlook.com'),
        ),
        ListTile(
          leading: Icon(Icons.stars),
          title: Text(I18n.of(context).support),
          subtitle: SelectableText(I18n.of(context).support_message),
        ),
        ListTile(
          leading: Icon(Icons.favorite),
          title: Text(I18n.of(context).thanks),
          subtitle: Text('感谢帮助我测试的弹幕委员会群友们'),
          onTap: () {
            if (Platform.isAndroid)
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => Scaffold(
                        appBar: AppBar(),
                        body: ThanksList(),
                      )));
          },
        ),
        ListTile(
          leading: Icon(Icons.share),
          title: Text(I18n.of(context).share),
          subtitle: Text(I18n.of(context).share_this_app_link),
          onTap: () {
            if (Platform.isIOS) {
              Share.share('https://apps.apple.com/cn/app/pixez/id1494435126');
            }
          },
        ),
        if (Platform.isAndroid && !Constants.isGooglePlay) ...[
          ListTile(
            title: Text(I18n.of(context).donate_title),
            subtitle: Text(I18n.of(context).donate_message),
          ),
          Card(
            child: ListTile(
              title: Text('AliPay'),
              subtitle: SelectableText('912756674@qq.com'),
              onTap: () async {},
            ),
          ),
          Card(
            child: ListTile(
              title: Text('Wechat Pay'),
              subtitle: Text('tap'),
              onTap: () async {
                showDialog(
                    context: context,
                    builder: (_) {
                      return AlertDialog(
                        content: Image.asset(
                          'assets/images/weixin_qr.png',
                          width: 300,
                          height: 300,
                        ),
                      );
                    });
              },
            ),
          ),
        ],
        if (Platform.isIOS) ...[
          Card(
            child: ListTile(
              subtitle: Text('如果你觉得这个应用还不错，支持一下开发者吧!'),
              title: Text('支持开发者工作'),
              trailing: Text('12￥'),
              onTap: () async {
                BotToast.showText(text: 'try to Purchase');
                List<PurchasedItem> items = await FlutterInappPurchase.instance
                    .getPendingTransactionsIOS();
                for (var i in items) {
                  await FlutterInappPurchase.instance.finishTransaction(i);
                }
                await FlutterInappPurchase.instance.requestPurchase('support');
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

                List<PurchasedItem> items = await FlutterInappPurchase.instance
                    .getPendingTransactionsIOS();
                for (var i in items) {
                  await FlutterInappPurchase.instance.finishTransaction(i);
                }
                await FlutterInappPurchase.instance.requestPurchase('support1');
              },
            ),
          )
        ]
      ],
    );
  }
}
