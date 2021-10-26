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
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:pixez/component/new_version_chip.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/constants.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/recommend.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/about/thanks_list.dart';
import 'package:pixez/page/about/update_page.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class Contributor {
  final String name;
  final String avatar;
  final String url;
  final String content;

  Contributor(this.name, this.avatar, this.url, this.content);
}

class AboutPage extends StatefulWidget {
  final bool? newVersion;

  const AboutPage({Key? key, this.newVersion}) : super(key: key);

  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  List<Contributor> contributors = [
    Contributor(
        'Tragic Life',
        'https://avatars3.githubusercontent.com/u/16817202?v=4',
        'https://github.com/TragicLifeHu',
        '🌍'),
    Contributor(
        'Skimige',
        'https://avatars3.githubusercontent.com/u/9017470?v=4',
        'https://xyx.moe/',
        '📖'),
    Contributor('Xian', 'https://avatars1.githubusercontent.com/u/34748039?v=4',
        'https://github.com/itzXian', '🌍'),
    Contributor(
        'karin722',
        'https://avatars0.githubusercontent.com/u/54385201?v=4',
        'http://ivtune.net/',
        '🌍'),
    Contributor(
        'Romani-Archman',
        'https://avatars0.githubusercontent.com/u/68731023?v=4',
        'http://archman.fun/',
        '📖'),
    Contributor(
        'Henry-ZHR',
        'https://avatars1.githubusercontent.com/u/51886614?s=64&v=4',
        'https://github.com/Henry-ZHR',
        '💻'),
    Contributor(
        'Takase',
        'https://avatars0.githubusercontent.com/u/20792268?s=64&v=4',
        'https://github.com/takase1121',
        '🌍'),
    Contributor(
        'ChsBuffer',
        'https://avatars3.githubusercontent.com/u/33744752?s=64&v=4',
        'https://github.com/chsbuffer',
        '💻')
  ];

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
    final Stream purchaseUpdated = InAppPurchase.instance.purchaseStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription?.cancel();
    }, onError: (error) {
    }) as StreamSubscription<List<PurchaseDetails>>?;
    const Set<String> _kIds = <String>{'support', 'support1'};
    final ProductDetailsResponse response =
        await InAppPurchase.instance.queryProductDetails(_kIds);
    if (response.notFoundIDs.isNotEmpty) {
    }
    List<ProductDetails> pDetails = response.productDetails;
    products.clear();
    products.addAll(pDetails);
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      if (purchaseDetails.status == PurchaseStatus.pending) {
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {

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
    return Scaffold(
      appBar: AppBar(
        title: Text(I18n.of(context).about),
        actions: <Widget>[],
      ),
      body: _buildInfo(context),
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
            onTap: () {
              showModalBottomSheet(
                context: context,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                builder: (BuildContext context) {
                  return InkWell(
                    onTap: () {
                      if (Platform.isAndroid)
                        launch(Constants.isGooglePlay
                            ? "https://music.youtube.com/watch?v=qfDhiBUNzwA&feature=share"
                            : "https://music.apple.com/cn/album/intrauterine-education-single/1515096587");
                    },
                    child: Container(
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
                    child: InkWell(
                      onTap: () async {
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
                              showModalBottomSheet(
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
                            showModalBottomSheet(
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
                            showModalBottomSheet(
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
                      child: Container(
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
            leading: Icon(Icons.rate_review),
            title: Text(I18n.of(context).rate_title),
            subtitle: Text(I18n.of(context).rate_message),
            onTap: () async {
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
              leading: Icon(Icons.device_hub),
              title: Text(I18n.of(context).repo_address),
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
            subtitle: Text('感谢帮助我测试的弹幕委员会群友们\n感谢pixiv cat站主提供的图床'),
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
          ListTile(
            leading: Icon(FontAwesomeIcons.telegram),
            title: Text("Group"),
            subtitle: SelectableText("t.me/PixEzViewer"),
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
                onTap: () async {
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
          // if (!Platform.isIOS &&
          //     iapStore.items.isNotEmpty &&
          //     Constants.isGooglePlay)
          //   for (var i in iapStore.items)
          //     Card(
          //       margin: EdgeInsets.all(8.0),
          //       elevation: 1.0,
          //       child: ListTile(
          //         leading: Icon(FontAwesomeIcons.coffee),
          //         title: Text(i.description ?? ""),
          //         subtitle: Text(i.localizedPrice ?? ""),
          //         onTap: () {
          //           FlutterInappPurchase.instance
          //               .requestPurchase(i.productId ?? "");
          //         },
          //       ),
          //     )
        ],
      );
    });
  }
}
