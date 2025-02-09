import 'dart:io';

import 'package:animations/animations.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/er/prefer.dart';
import 'package:pixez/main.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/about/languages.dart';
import 'package:pixez/fluent/page/Init/init_page.dart';
import 'package:pixez/fluent/page/network/network_page.dart';

class GuidePage extends StatefulWidget {
  @override
  _GuidePageState createState() => _GuidePageState();
}

class _GuidePageState extends State<GuidePage> {
  late List<Widget> _pageList;
  int index = 0;
  bool isNext = true;

  @override
  void initState() {
    _pageList = [InitPage(), NetworkPage()];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      content: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: PageTransitionSwitcher(
                duration: const Duration(milliseconds: 300),
                reverse: !isNext,
                transitionBuilder: (
                  Widget child,
                  Animation<double> animation,
                  Animation<double> secondaryAnimation,
                ) {
                  return SharedAxisTransition(
                    child: child,
                    animation: animation,
                    secondaryAnimation: secondaryAnimation,
                    transitionType: SharedAxisTransitionType.horizontal,
                  );
                },
                child: _pageList[index],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  AnimatedOpacity(
                    duration: Duration(milliseconds: 300),
                    opacity: index == 0 ? 0 : 1,
                    child: HyperlinkButton(
                      onPressed: () {
                        int backValue = index - 1;
                        if (backValue == 1 || backValue == 0) {
                          setState(() {
                            index = backValue;
                            isNext = false;
                          });
                        }
                      },
                      child: const Text('BACK'),
                    ),
                  ),
                  FilledButton(
                    onPressed: () async {
                      int nextValue = index + 1;
                      if (nextValue == 1) {
                        await Prefer.setInt(
                            'language_num', userSetting.languageNum);
                        //有可能用户啥都没选
                        final languageList =
                            Languages.map((e) => e.language).toList();
                        ApiClient.Accept_Language =
                            languageList[userSetting.languageNum];
                        apiClient.httpClient.options
                                .headers[HttpHeaders.acceptLanguageHeader] =
                            ApiClient.Accept_Language;
                        setState(() {
                          index = nextValue;
                          isNext = true;
                        });
                      } else if (nextValue == 2) {
                        await Prefer.setBool('guide_enable', false);
                        Leader.pushUntilHome(context);
                      }
                    },
                    child: const Text('NEXT'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
