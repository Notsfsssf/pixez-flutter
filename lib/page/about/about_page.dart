import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixez/bloc/iap_bloc.dart';
import 'package:pixez/bloc/iap_event.dart';
import 'package:pixez/bloc/iap_state.dart';
import 'package:pixez/generated/i18n.dart';
import 'package:pixez/page/about/bloc/about_bloc.dart';
import 'package:pixez/page/about/bloc/bloc.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
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
            ),
            ListTile(
              leading: Icon(Icons.rate_review),
              title: Text('如果你觉得PixEz还不错'),
              subtitle: Text('好评鼓励一下吧！'),
              onTap: () async {
                var url ='https://apps.apple.com/cn/app/pixez/id1494435126';
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
              onTap: (){
                Share.share('https://apps.apple.com/cn/app/pixez/id1494435126');
              },
            ),
            Card(
              child: ListTile(
                subtitle: Text('如果你觉得这个应用还不错，支持一下开发者吧!'),
                title: Text('支持开发者工作'),
                trailing: Text('12￥'),
                onTap: () {
                  BotToast.showText(text: 'try to Purchase');
                  BlocProvider.of<IapBloc>(context).add(MakeIapEvent('support'));
                },
              ),
            ),
                Card(
              child: ListTile(
                subtitle: Text('如果你觉得这个应用非常不错，支持一下开发者吧！'),
                title: Text('支持开发者工作'),
                trailing: Text('25￥'),
                onTap: () {
                  BotToast.showText(text: 'try to Purchase');
                  BlocProvider.of<IapBloc>(context).add(MakeIapEvent('support1'));
                },
              ),
            )
          ],
        );
      }),
    );
  }
}
