import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pixez/bloc/account_bloc.dart';
import 'package:pixez/bloc/account_event.dart';
import 'package:pixez/bloc/account_state.dart';
import 'package:pixez/component/painter_avatar.dart';
import 'package:pixez/generated/i18n.dart';
import 'package:pixez/page/about/about_page.dart';
import 'package:pixez/page/account/edit/account_edit_page.dart';
import 'package:pixez/page/account/select/account_select_page.dart';
import 'package:pixez/page/history/history_page.dart';
import 'package:pixez/page/iap/iap_page.dart';
import 'package:pixez/page/login/login_page.dart';
import 'package:pixez/page/progress/progress_page.dart';
import 'package:pixez/page/shield/shield_page.dart';

class SettingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(I18n.of(context).Setting),
      ),
      body: BlocListener<AccountBloc, AccountState>(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  BlocBuilder<AccountBloc, AccountState>(
                      builder: (context, snapshot) {
                    if (snapshot is HasUserState)
                      return Card(
                        child: BlocBuilder<AccountBloc, AccountState>(
                          builder: (BuildContext context, AccountState state) {
                            if (state is HasUserState) {
                              return SingleChildScrollView(
                                child: Column(
                                  children: <Widget>[
                                    ListTile(
                                      leading: PainterAvatar(
                                        url: state.list.userImage,
                                        id: int.parse(state.list.userId),
                                      ),
                                      title: Text(state.list.name),
                                      subtitle: Text(state.list.mailAddress),
                                      onTap: () {
                                        Navigator.of(context,
                                            rootNavigator: true)
                                            .push(
                                            MaterialPageRoute(builder: (_) {
                                              return AccountSelectPage();
                                            }));
                                      },
                                    ),
                                    ListTile(
                                      leading: Icon(Icons.account_box),
                                      title: Text(
                                          I18n
                                              .of(context)
                                              .Account_Message),
                                      onTap: () {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder:
                                                    (BuildContext context) =>
                                                    AccountEditPage()));
                                      },
                                    )
                                      ],
                                    ),
                                  );
                                }
                                return Container();
                              },
                            ),
                          );
                        return Container();
                      }),
                  Card(
                    child: Column(
                      children: <Widget>[
                        ListTile(
                          leading: Icon(Icons.history),
                          title: Text(I18n
                              .of(context)
                              .History_record),
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (BuildContext context) {
                                  return HistoryPage();
                            }));
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.brightness_auto),
                          title: Text(I18n.of(context).Shielding_settings),
                          onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      ShieldPage())),
                        ),
                        ListTile(
                          leading: Icon(Icons.description),
                          title: Text(I18n.of(context).Task_progress),
                          onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      ProgressPage())),
                        ),
                        ListTile(
                          onTap: () async {
                            final result = await showCupertinoDialog(
                                builder: (BuildContext context) {
                                  return CupertinoAlertDialog(
                                    title: Text("Warning"),
                                    content: Text("Clear all tempFile?"),
                                    actions: <Widget>[
                                      CupertinoDialogAction(
                                        child: Text("OK"),
                                        onPressed: () {
                                          Navigator.of(context).pop("OK");
                                        },
                                      ),
                                      CupertinoDialogAction(
                                        child: Text("CANCEL"),
                                        onPressed: () {
                                          Navigator.of(context).pop("CANCEL");
                                        },
                                        isDestructiveAction: true,
                                      )
                                    ],
                                  );
                                },
                                context: context);
                            switch (result) {
                              case "OK":
                                {
                                  Directory tempDir =
                                      await getTemporaryDirectory();
                                  tempDir.deleteSync(recursive: true);
                                }
                                break;
                            }
                          },
                          title: Text(I18n.of(context).Clearn_cache),
                          leading: Icon(Icons.clear),
                        ),
                      ],
                    ),
                  ),
                  Card(
                    child: Column(
                      children: <Widget>[
                        Visibility(
                          visible: false,
                          child: ListTile(
                            leading: Icon(Icons.lock),
                            title: Text(I18n.of(context).Donation),
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => IapPage()));
                            },
                          ),
                        ),
                        ListTile(
                          leading: Icon(Icons.message),
                          title: Text(I18n
                              .of(context)
                              .About),
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => AboutPage()));
                          },
                        ),
                        BlocBuilder<AccountBloc, AccountState>(
                            builder: (context, snapshot) {
                              if (snapshot is HasUserState)
                                return ListTile(
                                  leading: Icon(Icons.arrow_back),
                                  title: Text(I18n
                                      .of(context)
                                      .Logout),
                                  onTap: () async {
                                    final result = await showCupertinoDialog(
                                        builder: (BuildContext context) {
                                          return CupertinoAlertDialog(
                                            title: Text(I18n
                                                .of(context)
                                                .Logout),
                                            content: Text(
                                                I18n
                                                    .of(context)
                                                    .Logout_message),
                                            actions: <Widget>[
                                              CupertinoDialogAction(
                                                child: Text("OK"),
                                                onPressed: () {
                                                  Navigator.of(context).pop(
                                                      "OK");
                                                },
                                              ),
                                              CupertinoDialogAction(
                                                child: Text("CANCEL"),
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pop("CANCEL");
                                                },
                                                isDestructiveAction: true,
                                              )
                                            ],
                                          );
                                        },
                                        context: context);
                                    switch (result) {
                                      case "OK":
                                        {
                                          BlocProvider.of<AccountBloc>(context)
                                              .add(DeleteAllAccountEvent());
                                        }
                                        break;
                                      case "CANCEL":
                                        {}
                                        break;
                                    }
                                  },
                                );
                              else
                                return ListTile(
                                  leading: Icon(Icons.arrow_back),
                                  title: Text(I18n
                                      .of(context)
                                      .Login),
                                  onTap: () =>
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  LoginPage())),
                                );
                            })
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        listener: (BuildContext context, AccountState state) {
          if (state is NoneUserState) {
            Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => LoginPage()),
              (route) => route == null,
            );
          }
        },
      ),
    );
  }
}
