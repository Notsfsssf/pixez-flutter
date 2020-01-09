import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:pixez/page/follow/follow_page.dart';
import 'package:pixez/page/user/bloc/bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class UserDetailPage extends StatefulWidget {
  @override
  _UserDetailPageState createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  Widget _dataText(String string) => Text(
        string,
        style: TextStyle(color: Theme.of(context).primaryColor),
      );

  List<Widget> buildProfile(UserDataState state) {
// state.userDetail.profile_publicity.
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: BlocProvider.of<UserBloc>(context),
      builder: (context, state) {
        if (state is UserDataState) {
          final detail = state.userDetail;
          final public = detail.profile_publicity;
          final profile = detail.profile;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DataTable(
                    columns: <DataColumn>[
                      DataColumn(label: Text("Name")),
                      DataColumn(label: Text("Value")),
                    ],
                    rows: <DataRow>[
                      DataRow(cells: [
                        DataCell(Text('Total follow users')),
                        DataCell(
                            Text(detail.profile.total_follow_users.toString()),
                            onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (BuildContext context) {
                            return FollowPage(state.userDetail.user.id);
                          }));
                        }),
                      ]),
                      DataRow(cells: [
                        DataCell(Text('Total mypixiv users')),
                        DataCell(Text(
                            detail.profile.total_mypixiv_users.toString())),
                      ]),
                      DataRow(cells: [
                        DataCell(Text('Twitter account')),
                        DataCell(Text(profile.twitter_account),
                            onTap: () async {
                          final url = profile.twitter_url;
                          if (await canLaunch(url)) {
                            await launch(url);
                          } else {}
                        }),
                      ]),
                      DataRow(cells: [
                        DataCell(Text('Gender')),
                        DataCell(Text(detail.profile.gender)),
                      ]),
                      DataRow(cells: [
                        DataCell(Text('Job')),
                        DataCell(Text(detail.profile.job)),
                      ]),
                      DataRow(cells: [
                        DataCell(Text('Pawoo')),
                        DataCell(Text(public.pawoo ? 'Link' : 'none'),
                            onTap: () async {
                          if (!public.pawoo) return;
                          var url = detail.profile.pawoo_url;
                          if (await canLaunch(url)) {
                            await launch(url);
                          } else {}
                        }),
                      ]),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    child: Html(data: state.userDetail.user.comment),
                  ),
                ),
                Container(
                  height: 200,
                )
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
