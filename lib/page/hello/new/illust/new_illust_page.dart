
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:pixez/generated/l10n.dart';
import 'package:pixez/lighting/lighting_page.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/lighting/lighting_store.dart';

class NewIllustPage extends StatefulWidget {
  final String restrict;

  const NewIllustPage({Key key, this.restrict = "all"}) : super(key: key);

  @override
  _NewIllustPageState createState() => _NewIllustPageState();
}

class _NewIllustPageState extends State<NewIllustPage>
    with AutomaticKeepAliveClientMixin {
  FutureGet futureGet;

  @override
  void initState() {
    futureGet = () => RepositoryProvider.of<ApiClient>(context)
        .getFollowIllusts(widget.restrict);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return LightingList(
      header: Container(
          child: Align(
        alignment: Alignment.centerRight,
        child: IconButton(
            icon: Icon(Icons.list),
            onPressed: () {
              showModalBottomSheet(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  context: context,
                  builder: (context) => SafeArea(
                    child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            ListTile(
                              title: Text(I18n.of(context).All),
                              onTap: () {
                                Navigator.of(context).pop();
                                setState(() {
                                  futureGet = () =>
                                      RepositoryProvider.of<ApiClient>(context)
                                          .getFollowIllusts('all');
                                });
                              },
                            ),
                            ListTile(
                              title: Text(I18n.of(context).public),
                              onTap: () {
                                Navigator.of(context).pop();
                                setState(() {
                                  futureGet = () =>
                                      RepositoryProvider.of<ApiClient>(context)
                                          .getFollowIllusts('public');
                                });
                              },
                            ),
                            ListTile(
                              title: Text(I18n.of(context).private),
                              onTap: () {
                                Navigator.of(context).pop();
                                setState(() {
                                  futureGet = () =>
                                      RepositoryProvider.of<ApiClient>(context)
                                          .getFollowIllusts('private');
                                });
                              },
                            ),
                          ],
                        ),
                  ));
            }),
      )),
      source: futureGet,
    );
  }

  @override
  bool get wantKeepAlive => true;
}
