import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pixez/component/selectable_html.dart';
import 'package:pixez/generated/l10n.dart';
import 'package:pixez/models/user_detail.dart';
import 'package:pixez/page/follow/follow_list.dart';
import 'package:url_launcher/url_launcher.dart';

class UserDetailPage extends StatefulWidget {
  final UserDetail userDetail;

  const UserDetailPage({Key key, @required this.userDetail}) : super(key: key);

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
    if (widget.userDetail == null) {
      return Container();
    }
    var detail = widget.userDetail;
    var profile = widget.userDetail.profile;
    var public = widget.userDetail.profile_publicity;
    return widget.userDetail != null
        ? SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    child: widget.userDetail.user.comment.isNotEmpty
                        ? SelectableHtml(data: widget.userDetail.user.comment)
                        : SelectableHtml(
                            data: '~',
                          ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DataTable(
                    columns: <DataColumn>[
                      DataColumn(label: Text("Name")),
                      DataColumn(
                          label: Expanded(
                              child: SelectableText(detail.user.name))),
                    ],
                    rows: <DataRow>[
                      DataRow(cells: [
                        DataCell(Text('Total follow users')),
                        DataCell(
                            Text(detail.profile.total_follow_users.toString()),
                            onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (BuildContext context) {
                            return Scaffold(
                              appBar: AppBar(
                                title: Text(I18n.of(context).Search),
                              ),
                              body: FollowList(id: widget.userDetail.user.id),
                            );
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
                Container(
                  height: 200,
                )
              ],
            ),
          )
        : Container();
  }
}
