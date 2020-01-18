import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBody: true,
      extendBodyBehindAppBar: true,
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
          subtitle: Text('使用flutter开发'),
        ),
        ListTile(
          leading: Icon(Icons.email),
          title: Text('GitHub Page'),
          subtitle: Text('https://github.com/Notsfsssf'),
          onTap: () async {},
        ),
        ListTile(
          leading: Icon(Icons.email),
          title: Text('FeedBack'),
          subtitle: SelectableText('PxezFeedBack@outlook.com'),
        ),
      ],
    );
  }
}
