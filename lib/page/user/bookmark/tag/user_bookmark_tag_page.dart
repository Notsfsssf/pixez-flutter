import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:pixez/bloc/account_bloc.dart';
import 'package:pixez/bloc/account_state.dart';
import 'package:pixez/generated/i18n.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/user/bookmark/tag/bloc.dart';

class UserBookmarkTagPage extends StatefulWidget {
  @override
  _UserBookmarkTagPageState createState() => _UserBookmarkTagPageState();
}

class _UserBookmarkTagPageState extends State<UserBookmarkTagPage> {
  String restrict = 'public';

  @override
  Widget build(BuildContext context) {
    AccountBloc accountBloc = BlocProvider.of<AccountBloc>(context);
    return BlocProvider<UserBookmarkTagBloc>(
      create: (context) =>
          UserBookmarkTagBloc(RepositoryProvider.of<ApiClient>(context)),
      child: BlocBuilder<UserBookmarkTagBloc, UserBookmarkTagState>(
          builder: (context, snapshot) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Tag'),
            bottom: TabBar(
              tabs: <Widget>[
                Tab(
                  text: I18n.of(context).Public,
                ),
                Tab(
                  text: I18n.of(context).Private,
                ),
              ],
              onTap: (index) {
                var state = accountBloc.state;
                if (state is HasUserState) {
                  switch (index) {
                    case 0:
                      {
                        restrict = 'public';
                        BlocProvider.of<UserBookmarkTagBloc>(context).add(
                            FetchUserBookmarkTagEvent(state.list.id, restrict));
                      }
                      break;
                    case 1:
                      {
                        restrict = 'private';
                        BlocProvider.of<UserBookmarkTagBloc>(context).add(
                            FetchUserBookmarkTagEvent(state.list.id, restrict));
                      }
                      break;
                  }
                }
              },
            ),
          ),
          body: Container(
            child: EasyRefresh(
              child: snapshot is DataUserBookmarkTagState
                  ? ListView.builder(itemBuilder: (context, index) {
                      var bookmarkTag = snapshot.bookmarkTags[index];
                      return ListTile(
                        title: Text(bookmarkTag.name),
                        trailing: Text(bookmarkTag.count.toString()),
                        onTap: () {
                          Navigator.pop(context, bookmarkTag.name);
                        },
                      );
                    })
                  : Container(
                      child: CircularProgressIndicator(),
                    ),
              onRefresh: () {
                var state = accountBloc.state;
                if (state is HasUserState)
                  BlocProvider.of<UserBookmarkTagBloc>(context)
                      .add(FetchUserBookmarkTagEvent(state.list.id, restrict));
                return;
              },
              onLoad: () {},
            ),
          ),
        );
      }),
    );
  }
}
