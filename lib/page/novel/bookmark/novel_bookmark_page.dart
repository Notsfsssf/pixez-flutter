import 'package:flutter/material.dart';
import 'package:pixez/generated/l10n.dart';
import 'package:pixez/lighting/lighting_store.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/novel/component/novel_lighting_list.dart';

class NovelBookmarkPage extends StatefulWidget {
  final int id;

  const NovelBookmarkPage({Key key, this.id}) : super(key: key);
  @override
  _NovelBookmarkPageState createState() => _NovelBookmarkPageState();
}

class _NovelBookmarkPageState extends State<NovelBookmarkPage> {
  String restrict = 'public';
  FutureGet futureGet;
  @override
  void initState() {
    futureGet = () => apiClient.getUserBookmarkNovel(widget.id, restrict);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        IconButton(
            icon: Icon(Icons.list),
            onPressed: () {
              showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return SafeArea(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          ListTile(
                            title: Text(I18n.of(context).public),
                            onTap: () {
                              setState(() {
                                futureGet = () => apiClient.getUserBookmarkNovel(
                                    widget.id, 'public');
                              });
                              Navigator.of(context).pop();
                            },
                          ),
                          ListTile(
                            title: Text(I18n.of(context).private),
                            onTap: () {
                              setState(() {
                                futureGet = () => apiClient.getUserBookmarkNovel(
                                    widget.id, 'private');
                              });
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                    );
                  });
            }),
        NovelLightingList(
          futureGet: futureGet,
        )
      ],
    );
  }
}
