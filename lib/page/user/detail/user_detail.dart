import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:pixez/page/user/bloc/bloc.dart';

class UserDetailPage extends StatefulWidget {
  @override
  _UserDetailPageState createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  Widget _dataText(String string) => Text(
        string,
        style: TextStyle(color: Theme.of(context).primaryColor),
      );

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: BlocProvider.of<UserBloc>(context),
      builder: (context, state) {
        if (state is UserDataState) {
          final detail = state.userDetail;
          return Container(
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("data"),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: _dataText(
                          detail.profile.total_follow_users.toString()),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("data"),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: _dataText(detail
                          .profile.total_illust_bookmarks_public
                          .toString()),
                    ),
                  ],
                ),
                Card(child: Html(data: state.userDetail.user.comment)),
              ],
            ),
          );
        } else
          return Center(
            child: CircularProgressIndicator(),
          );
      },
    );
  }
}
