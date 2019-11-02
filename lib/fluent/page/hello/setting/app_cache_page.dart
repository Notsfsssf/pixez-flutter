import 'package:fluent_ui/fluent_ui.dart';
import 'package:pixez/i18n.dart';

class AppCachePage extends StatefulWidget {
  @override
  _AppCachePageState createState() => _AppCachePageState();
}

class _AppCachePageState extends State<AppCachePage> {
  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: PageHeader(
        title: Text('App Cache'),
      ),
      content: ListView(
        children: [
          ListTile(
            title: Text(I18n.of(context).clear_all_cache),
          ),
        ],
      ),
    );
  }
}
