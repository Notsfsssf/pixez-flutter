import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixez/bloc/bloc.dart';
import 'package:pixez/generated/i18n.dart';
import 'package:pixez/models/ban_user_id.dart';

class ShieldPage extends StatefulWidget {
  @override
  _ShieldPageState createState() => _ShieldPageState();
}

class _ShieldPageState extends State<ShieldPage> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MuteBloc, MuteState>(builder: (context, snapshot) {
      return Scaffold(
        appBar: AppBar(
          title: Text(I18n.of(context).Shielding_settings),
        ),
        body: snapshot is DataMuteState
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text(I18n.of(context).Painter),
                      Container(
                        child: Wrap(
                          spacing: 2.0,
                          runSpacing: 2.0,
                          direction: Axis.horizontal,
                          children: <Widget>[
                            ...snapshot.banUserIds
                                .map((f) => ActionChip(
                                      onPressed: () =>
                                          _deleteUserIdTag(context, f),
                                      label: Text(f.name),
                                    ))
                                .toList()
                          ],
                        ),
                      ),
                      Divider(),
                      Text(I18n.of(context).Illust),
                      Container(
                        child: Wrap(
                          spacing: 2.0,
                          runSpacing: 2.0,
                          direction: Axis.horizontal,
                          children: <Widget>[
                            ...snapshot.banIllustIds
                                .map((f) => ActionChip(
                                      onPressed: () async {
                                        final result = await showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title:
                                                  Text(I18n.of(context).Delete),
                                              content: Text('Delete this tag?'),
                                              actions: <Widget>[
                                                FlatButton(
                                                  onPressed: () {
                                                    Navigator.pop(
                                                        context, "OK");
                                                  },
                                                  child:
                                                      Text(I18n.of(context).OK),
                                                ),
                                                FlatButton(
                                                  child: Text(
                                                      I18n.of(context).Cancel),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                )
                                              ],
                                            );
                                          },
                                        );
                                        switch (result) {
                                          case "OK":
                                            {
                                              BlocProvider.of<MuteBloc>(context)
                                                  .add(DeleteIllustEvent(f.id));
                                            }
                                            break;
                                        }
                                      },
                                      label: Text(f.name),
                                    ))
                                .toList()
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : Container(),
      );
    });
  }

  Future _deleteUserIdTag(BuildContext context, BanUserIdPersist f) async {
    final result = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(I18n.of(context).Delete),
          content: Text('Delete this tag?'),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                Navigator.pop(context, "OK");
              },
              child: Text(I18n.of(context).OK),
            ),
            FlatButton(
              child: Text(I18n.of(context).Cancel),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
    switch (result) {
      case "OK":
        {
          BlocProvider.of<MuteBloc>(context).add(DeleteUserEvent(f.id));
        }
        break;
    }
  }
}
