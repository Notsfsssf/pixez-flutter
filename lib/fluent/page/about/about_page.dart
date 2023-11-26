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
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'package:pixez/fluent/component/new_version_chip.dart';
import 'package:pixez/constants.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/page/about/contributors.dart';
import 'package:pixez/fluent/page/about/thanks_list.dart';
import 'package:pixez/fluent/page/about/update_page.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatefulWidget {
  final bool? newVersion;

  const AboutPage({Key? key, this.newVersion}) : super(key: key);

  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  late bool hasNewVersion;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  List<ProductDetails> products = [];

  @override
  void initState() {
    initIap();
    hasNewVersion = widget.newVersion ?? false;
    super.initState();
  }

  initIap() async {
    if (!Constants.isGooglePlay && !Platform.isIOS) return;
    final Stream purchaseUpdated = InAppPurchase.instance.purchaseStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription?.cancel();
    }, onError: (error) {}) as StreamSubscription<List<PurchaseDetails>>?;
    const Set<String> _kIds = <String>{'support', 'support1'};
    final ProductDetailsResponse response =
        await InAppPurchase.instance.queryProductDetails(_kIds);
    if (response.notFoundIDs.isNotEmpty) {}
    List<ProductDetails> pDetails = response.productDetails;
    products.clear();
    products.addAll(pDetails);
    if (Platform.isIOS && products.isNotEmpty) {
      try {
        var transactions = await SKPaymentQueueWrapper().transactions();
        transactions.forEach((skPaymentTransactionWrapper) {
          SKPaymentQueueWrapper()
              .finishTransaction(skPaymentTransactionWrapper);
        });
      } catch (e) {}
    }
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      if (purchaseDetails.status == PurchaseStatus.pending) {
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          BotToast.showText(text: "Thanks");
        }
        if (purchaseDetails.pendingCompletePurchase) {
          await InAppPurchase.instance.completePurchase(purchaseDetails);
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: PageHeader(
        title: Text(I18n.of(context).about),
      ),
      content: _buildInfo(context),
    );
  }

  Widget _buildInfo(BuildContext context) {
    return Observer(builder: (context) {
      return ListView(
        children: <Widget>[
          ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage('assets/images/me.jpg'),
            ),
            title: Text('Perol_Notsfsssf'),
            subtitle: Text(I18n.of(context).perol_message),
            onPressed: () {
              showDialog(
                context: context,
                barrierDismissible: true,
                builder: (context) => Padding(
                  padding: EdgeInsets.all(128),
                  child: IconButton(
                    onPressed: () async {
                      if (Platform.isAndroid)
                        await launchUrl(Uri.parse(Constants.isGooglePlay
                            ? "https://music.youtube.com/watch?v=qfDhiBUNzwA&feature=share"
                            : "https://music.apple.com/cn/album/intrauterine-education-single/1515096587"));
                    },
                    icon: Container(
                      child: Image.asset(
                        'assets/images/liz.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage('assets/images/right_now.jpg'),
            ),
            title: Text('Right now'),
            subtitle: Text(I18n.of(context).right_now_message),
            onPressed: () {
              showDialog(
                context: context,
                barrierDismissible: true,
                builder: (context) => Container(
                  height: 200.0,
                  child: Center(
                    child: Text("这里空空的，这个设计师显然没有什么话要说"),
                  ),
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Contributors'),
          ),
          Container(
            height: 162,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: contributors.length,
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.only(left: 4.0),
              itemBuilder: (context, index) {
                final data = contributors[index];
                return Container(
                  margin: EdgeInsets.only(left: 4.0, top: 4.0, bottom: 4.0),
                  child: IconButton(
                    onPressed: () async {
                      try {
                        if (data.onPressed == null) return;
                        await data.onPressed!(context);
                      } catch (e) {}
                    },
                    icon: Container(
                      width: 80,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              Container(
                                height: 8,
                              ),
                              CircleAvatar(
                                backgroundImage: NetworkImage(
                                  data.avatar,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  data.name,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              data.content,
                              textAlign: TextAlign.center,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          ListTile(
            leading: Icon(FluentIcons.rate),
            title: Text(I18n.of(context).rate_title),
            subtitle: Text(I18n.of(context).rate_message),
            onPressed: () async {
              if (Platform.isIOS) {
                var url = 'https://apps.apple.com/cn/app/pixez/id1494435126';
                try {
                  await launchUrl(Uri.parse(url));
                } catch (e) {}
              }
            },
          ),
          if (Platform.isAndroid) ...[
            ListTile(
              leading: Icon(FluentIcons.device_off),
              title: Text(I18n.of(context).repo_address),
              subtitle: Text('github.com/Notsfsssf/pixez-flutter'),
              trailing: Visibility(
                child: NewVersionChip(),
                visible: hasNewVersion,
              ),
              onPressed: () {
                if (!Constants.isGooglePlay)
                  showDialog(
                      context: context,
                      builder: (_) {
                        return SafeArea(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              ListTile(
                                title: Text('Version ${Constants.tagName}'),
                                subtitle: Text(
                                    I18n.of(context).go_to_project_address),
                                onPressed: () async {
                                  try {
                                    await launchUrl(Uri.parse(
                                        'https://github.com/Notsfsssf/pixez-flutter'));
                                  } catch (e) {}
                                },
                                trailing: IconButton(
                                    icon: Icon(FluentIcons.link),
                                    onPressed: () async {
                                      try {
                                        await launchUrl(Uri.parse(
                                            'https://github.com/Notsfsssf/pixez-flutter'));
                                      } catch (e) {}
                                    }),
                              ),
                              ListTile(
                                title: Text(I18n.of(context).check_for_updates),
                                onPressed: () {
                                  Leader.push(
                                    context,
                                    UpdatePage(),
                                    icon: Icon(FluentIcons.update_restore),
                                    title: Text(
                                        I18n.of(context).check_for_updates),
                                  );
                                },
                                trailing: Icon(FluentIcons.update_restore),
                              ),
                              ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: NetworkImage(
                                      'https://avatars1.githubusercontent.com/u/9017470?s=400&v=4'),
                                ),
                                title: Text('Skimige'),
                                subtitle:
                                    Text(I18n.of(context).skimige_message),
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
                leading: Icon(FluentIcons.home),
                title: Text('GitHub Page'),
                subtitle: Text('https://github.com/Notsfsssf'),
                onPressed: () async {}),
          ),
          ListTile(
            leading: Icon(FluentIcons.mail),
            title: Text(I18n.of(context).feedback),
            subtitle: Text('PxezFeedBack@outlook.com'),
          ),
          ListTile(
            leading: Icon(FluentIcons.like),
            title: Text(I18n.of(context).support),
            subtitle: Text(I18n.of(context).support_message),
          ),
          ListTile(
            leading: Icon(FluentIcons.favorite_star),
            title: Text(I18n.of(context).thanks),
            subtitle: Text('感谢帮助我测试的弹幕委员会群友们\n感谢pixiv cat站主提供的图床'),
            onPressed: () {
              Leader.push(
                context,
                ScaffoldPage(content: ThanksList()),
                icon: Icon(FluentIcons.favorite_star),
                title: Text(I18n.of(context).thanks),
              );
            },
          ),
          ListTile(
            leading: Icon(FluentIcons.share),
            title: Text(I18n.of(context).share),
            subtitle: Text(I18n.of(context).share_this_app_link),
            onPressed: () {
              if (Platform.isIOS) {
                Share.share('https://apps.apple.com/cn/app/pixez/id1494435126');
              }
            },
          ),
          ListTile(
            leading: Icon(FontAwesomeIcons.telegram),
            title: Text("Group"),
            subtitle: Text('t.me/PixEzChannel'),
          ),
          if (Platform.isAndroid && !Constants.isGooglePlay) ...[
            ListTile(
              title: Text(I18n.of(context).donate_title),
              subtitle: Text(I18n.of(context).donate_message),
            ),
            Card(
              child: ListTile(
                title: Text('AliPay'),
                subtitle: Text('912756674@qq.com'),
                onPressed: () async {},
              ),
            ),
            Card(
              child: ListTile(
                title: Text('Wechat Pay'),
                subtitle: Text('tap'),
                onPressed: () async {
                  showDialog(
                      context: context,
                      builder: (_) {
                        return ContentDialog(
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
                onPressed: () async {
                  BotToast.showText(text: 'try to Purchase');
                  for (var p in products) {
                    if (p.id == "support") {
                      final PurchaseParam purchaseParam =
                          PurchaseParam(productDetails: p);
                      InAppPurchase.instance
                          .buyConsumable(purchaseParam: purchaseParam);
                      break;
                    }
                  }
                },
              ),
            ),
            Card(
              child: ListTile(
                subtitle: Text('如果你觉得这个应用非常不错，支持一下开发者吧！'),
                title: Text('支持开发者工作'),
                trailing: Text('25￥'),
                onPressed: () async {
                  BotToast.showText(text: 'try to Purchase');
                  for (var p in products) {
                    if (p.id == "support1") {
                      final PurchaseParam purchaseParam =
                          PurchaseParam(productDetails: p);
                      InAppPurchase.instance
                          .buyConsumable(purchaseParam: purchaseParam);
                      break;
                    }
                  }
                },
              ),
            ),
          ],
          if (!Platform.isIOS && products.isNotEmpty && Constants.isGooglePlay)
            for (var i in products)
              Card(
                margin: EdgeInsets.all(8.0),
                child: ListTile(
                  leading: Icon(FontAwesomeIcons.mugSaucer),
                  title: Text(i.description),
                  subtitle: Text(i.price),
                  onPressed: () {
                    BotToast.showText(text: 'try to Purchase');
                    final PurchaseParam purchaseParam =
                        PurchaseParam(productDetails: i);
                    InAppPurchase.instance
                        .buyConsumable(purchaseParam: purchaseParam);
                  },
                ),
              )
        ],
      );
    });
  }
}
