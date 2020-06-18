import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixez/bloc/account_bloc.dart';
import 'package:pixez/bloc/account_state.dart';
import 'package:pixez/bloc/bloc.dart';
import 'package:pixez/lighting/lighting_page.dart';
import 'package:pixez/main.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/user/bookmark/tag/user_bookmark_tag_page.dart';
import 'package:pixez/lighting/lighting_store.dart';

class BookmarkPage extends StatefulWidget {
  final int id;
  final String restrict;
  final String tag;

  const BookmarkPage(
      {Key key, @required this.id, this.restrict = "public", this.tag})
      : super(key: key);

  @override
  _BookmarkPageState createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage>
 {
  FutureGet futureGet;

  @override
  void initState() {
    futureGet = () => RepositoryProvider.of<ApiClient>(context)
        .getBookmarksIllust(widget.id, widget.restrict, null);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (accountStore.now != null) {
      if (int.parse(accountStore.now.userId) == widget.id) {
        return LightingList(
          source: futureGet,
          header: Container(
            child: Align(
              alignment: Alignment.topRight,
              child: IconButton(
                  icon: Icon(Icons.toys),
                  onPressed: () async {
                    final result = await Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => UserBookmarkTagPage()));
                    if (result != null) {
                      String tag = result['tag'];
                      String restrict = result['restrict'];
                      setState(() {
                        futureGet = () =>
                            RepositoryProvider.of<ApiClient>(context)
                                .getBookmarksIllust(widget.id, restrict, tag);
                      });
                    }
                  }),
            ),
          ),
        );
      }
      return LightingList(
        source: futureGet,
      );
    } else {
      return Container();
    }
  }

}
