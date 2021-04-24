import 'package:flutter/material.dart';
import 'package:pixez/i18n.dart';

class AppCachePage extends StatefulWidget {
  @override
  _AppCachePageState createState() => _AppCachePageState();
}

class _AppCachePageState extends State<AppCachePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('App Cache'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text(I18n.of(context).clear_all_cache),
          ),
        ],
      ),
    );
  }
}
