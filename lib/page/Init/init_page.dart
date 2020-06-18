import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/main.dart';
import 'package:pixez/page/hello/android_hello_page.dart';
import 'package:pixez/page/splash/splash_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InitPage extends StatefulWidget {
  @override
  _InitPageState createState() => _InitPageState();
}

class _InitPageState extends State<InitPage> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.arrow_forward),
          onPressed: () async {
            var prefs = await SharedPreferences.getInstance();
            await prefs.setInt('language_num', userSetting.languageNum);
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => AndroidHelloPage()));
          },
        ),
        body: Container(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Select Language语言选择"),
                ),
                Observer(builder: (_) {
                  return TabBar(
                    labelColor: Theme.of(context).textTheme.headline6.color,
                    indicatorSize: TabBarIndicatorSize.label,
                    tabs: [
                      Tab(
                        text: "en-US",
                      ),
                      Tab(
                        text: "zh-CN",
                      ),
                      Tab(
                        text: "zh-TW",
                      )
                    ],
                    onTap: (index) async {
                      await userSetting.setLanguageNum(index);
                      setState(() {});
                    },
                    controller: TabController(
                        length: 3,
                        vsync: this,
                        initialIndex: userSetting.languageNum),
                  );
                })
              ],
            ),
          ),
        ));
  }
}
