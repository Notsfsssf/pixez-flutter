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
import 'dart:math';

import 'package:bot_toast/bot_toast.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:pixez/component/fluent/new_version_chip.dart';
import 'package:pixez/component/fluent/pixiv_image.dart';
import 'package:pixez/constants.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/recommend.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/about/contributors.dart';
import 'package:pixez/page/fluent/about/thanks_list.dart';
import 'package:pixez/page/fluent/about/update_page.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';

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
              showBottomSheet(
                context: context,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                builder: (BuildContext context) {
                  return IconButton(
                    onPressed: () {
                      if (Platform.isAndroid)
                        launch(Constants.isGooglePlay
                            ? "https://music.youtube.com/watch?v=qfDhiBUNzwA&feature=share"
                            : "https://music.apple.com/cn/album/intrauterine-education-single/1515096587");
                    },
                    icon: Container(
                      child: Image.asset(
                        'assets/images/liz.png',
                        fit: BoxFit.cover,
                      ),
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
            onPressed: () {
              showBottomSheet(
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Contributors'),
          ),
          Container(
            height: 142,
            padding: EdgeInsets.only(left: 8.0),
            child: ListView.builder(
                shrinkWrap: true,
                itemCount: contributors.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  final data = contributors[index];
                  return Card(
                    child: IconButton(
                      onPressed: () async {
                        if (index == 0 && accountStore.now != null) {
                          //Tragic Life:輪播凱留TAG 10000+收藏的圖
                          try {
                            if (Platform.isAndroid) {
                              final response = await apiClient
                                  .getSearchIllust("キャル(プリコネ) 10000users入り");
                              Recommend recommend =
                                  Recommend.fromJson(response.data);
                              if (recommend.illusts.isEmpty) return;
                              int i = Random()
                                  .nextInt(recommend.illusts.length - 1);
                              if (i < 0 || i >= recommend.illusts.length) i = 0;
                              showBottomSheet(
                                  context: context,
                                  builder: (context) {
                                    return SafeArea(
                                        child: PixivImage(recommend
                                            .illusts[0].imageUrls.medium));
                                  });
                            }
                          } catch (e) {}
                        }
                        if (index == 1) {
                          //☆:“都给我去看 FAQ！”
                          String text = Platform.isIOS || Constants.isGooglePlay
                              ? "R！T！F！M！"
                              : "Read The Fucking Manual!";
                          BotToast.showText(text: text);
                        }
                        if (index == 2 && accountStore.now != null) {
                          //XIAN:随机加载一张色图
                          if (Platform.isIOS || Constants.isGooglePlay) return;
                          try {
                            final response = await apiClient.getIllustRanking(
                                'day_r18', null);
                            Recommend recommend =
                                Recommend.fromJson(response.data);
                            showBottomSheet(
                                context: context,
                                builder: (context) {
                                  return SafeArea(
                                      child: PixivImage(recommend
                                          .illusts[Random().nextInt(10)]
                                          .imageUrls
                                          .medium));
                                });
                          } catch (e) {}
                        }
                        if (index == 4) {
                          //GC:摸一摸可爱的鱼
                          if (Platform.isIOS || Constants.isGooglePlay) {
                            //摸不了,来点tips
                            var RA_Tips = [
                              "FAQ是个好东西",
                              "想摸鱼,但摸不了",
                              "为啥他们都会飞镖",
                              "正在开启青壮年模式(假的",
                              "别戳了,会怀孕的",
                              "我有一个很好的想法,但这写不下"
                            ];
                            BotToast.showText(
                                text: RA_Tips[Random().nextInt(7)]);
                          } else {
                            showBottomSheet(
                                context: context,
                                builder: (context) {
                                  return SafeArea(
                                      child: Image.asset(
                                    'assets/images/fish.gif',
                                    fit: BoxFit.cover,
                                  ));
                                });
                          }
                        }
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
                }),
          ),
          ListTile(
            leading: Icon(FluentIcons.rate),
            title: Text(I18n.of(context).rate_title),
            subtitle: Text(I18n.of(context).rate_message),
            onPressed: () async {
              if (Platform.isIOS) {
                var url = 'https://apps.apple.com/cn/app/pixez/id1494435126';
                try {
                  await launch(url);
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
                  showBottomSheet(
                      context: context,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                              top: Radius.circular(16.0))),
                      builder: (_) {
                        return SafeArea(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              ListTile(
                                title: Text('Version ${Constants.tagName}'),
                                subtitle: Text(
                                    I18n.of(context).go_to_project_address),
                                onPressed: () {
                                  try {
                                    launch(
                                        'https://github.com/Notsfsssf/pixez-flutter');
                                  } catch (e) {}
                                },
                                trailing: IconButton(
                                    icon: Icon(FluentIcons.link),
                                    onPressed: () {
                                      try {
                                        launch(
                                            'https://github.com/Notsfsssf/pixez-flutter');
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
                  leading: Icon(FontAwesomeIcons.coffee),
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
