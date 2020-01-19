import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixez/generated/i18n.dart';
import 'package:pixez/page/about/bloc/about_bloc.dart';
import 'package:pixez/page/about/bloc/bloc.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<AboutBloc>(
      child: Scaffold(
        appBar: AppBar(
          title: Text("About"),
        ),
        body: _buildInfo(context),
      ),
      create: (BuildContext context) => AboutBloc(),
    );
  }

  Widget _buildInfo(BuildContext context) {
    return BlocBuilder<AboutBloc, AboutState>(builder: (context, snapshot) {
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
            leading: Icon(Icons.home),
            title: Text('GitHub Page'),
            subtitle: Text('https://github.com/Notsfsssf'),
            onTap: () async {},
          ),
          ListTile(
            leading: Icon(Icons.email),
            title: Text(I18n.of(context).FeedBack),
            subtitle: SelectableText('PxezFeedBack@outlook.com'),
          ),
        ],
      );
    });
  }
}
