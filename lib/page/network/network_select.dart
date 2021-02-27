import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/main.dart';
import 'package:pixez/page/hello/android_hello_page.dart';
import 'package:pixez/page/hello/hello_page.dart';
import 'package:pixez/page/network/network_page.dart';

class NetworkSelectPage extends StatefulWidget {
  @override
  _NetworkSelectPageState createState() => _NetworkSelectPageState();
}

class _NetworkSelectPageState extends State<NetworkSelectPage>
    with TickerProviderStateMixin {
  TabController tabController;

  @override
  void initState() {
    tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: userSetting.disableBypassSni ? 1 : 0,
    );
    super.initState();
  }

  @override
  void dispose() {
    tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      return Scaffold(
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.arrow_forward),
          onPressed: () async {
            await userSetting.setDisableBypassSni(tabController.index != 0);
            if (userSetting.disableBypassSni) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (context) =>
                        Platform.isIOS ? HelloPage() : AndroidHelloPage()),
                (route) => route == null,
              );
            } else {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => NetworkPage()),
              );
            }
          },
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TabBar(
              controller: tabController,
              tabs: [
                Tab(
                  text: "China",
                ),
                Tab(
                  text: "Not in China",
                ),
              ],
              onTap: (index) async {
                await userSetting.setDisableBypassSni(index != 0);
              },
            ),
          ),
        ),
      );
    });
  }
}
