import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixez/bloc/account_bloc.dart';
import 'package:pixez/bloc/account_event.dart';
import 'package:pixez/bloc/save_bloc.dart';
import 'package:pixez/bloc/save_state.dart';
import 'package:pixez/generated/i18n.dart';
import 'package:pixez/models/create_user_response.dart';
import 'package:pixez/network/oauth_client.dart';
import 'package:pixez/page/create/user/create_user_page.dart';
import 'package:pixez/page/guid/guid_page.dart';
import 'package:pixez/page/hello/hello_page.dart';
import 'package:pixez/page/login/bloc/bloc.dart';
import 'package:pixez/page/login/bloc/login_bloc.dart';
import 'package:pixez/page/preview/preview_page.dart';
import 'package:url_launcher/url_launcher.dart';

import 'bloc/login_event.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    TextEditingController userNameController = TextEditingController(text: "");
    TextEditingController passWordController = TextEditingController(text: "");
    return BlocProvider(
        create: (context) =>
            LoginBloc(RepositoryProvider.of<OAuthClient>(context)),
        child: BlocBuilder<LoginBloc, LoginState>(builder: (context, snapshot) {
          return Scaffold(
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () async {
                final result = await Navigator.of(context)
                    .push(MaterialPageRoute(builder: (BuildContext context) {
                  return CreateUserPage();
                }));
                if (result != null && result is CreateUserResponse) {
                  userNameController.text = result.body.userAccount;
                  passWordController.text = result.body.password;
                  BlocProvider.of<LoginBloc>(context).add(ClickToAuth(
                      username: userNameController.value.text.trim(),
                      password: passWordController.value.text.trim(),
                      deviceToken: result.body.deviceToken));
                }
              },
              icon: Icon(Icons.arrow_forward),
              label: Text("New？"),
            ),
            body: SafeArea(
              child: BlocListener<LoginBloc, LoginState>(
                listener: (context, state) {
                  if (state is SuccessState) {
                    BlocProvider.of<AccountBloc>(context)
                        .add(FetchDataBaseEvent());
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (BuildContext context) =>
                            BlocListener<SaveBloc, SaveState>(
                                listener: (context, state) {
                                  if (state is SaveSuccesState)
                                    BotToast.showNotification(
                                        leading: (_) => Icon(Icons.save_alt),
                                        title: (_) =>
                                            Text(I18n.of(context).Saved));
                                  if (state is SaveAlreadyGoingOnState)
                                    BotToast.showNotification(
                                        leading: (_) => Icon(Icons.save_alt),
                                        title: (_) => Text(
                                            I18n.of(context).Already_in_query));
                                },
                                child: HelloPage())));
                  } else if (state is FailState) {
                    Scaffold.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.red,
                        content: Text(state.failMessage),
                      ),
                    );
                  }
                  if (state is NeedGuidState) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => GuidPage()));
                  }
                },
                child: SingleChildScrollView(
                    child: Column(
                  children: <Widget>[
                    Container(
                      height: 20,
                    ),
                    Image.asset(
                      'assets/images/icon.png',
                      height: 80,
                      width: 80,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Container(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          children: <Widget>[
                            TextFormField(
                              maxLines: 1,
                              decoration: const InputDecoration(
                                icon: Icon(Icons.supervised_user_circle),
                                hintText: 'Pixiv id/Email',
                                labelText: 'Pixiv id/Email',
                              ),
                              controller: userNameController,
                            ),
                            Padding(
                              padding: EdgeInsets.all(10),
                            ),
                            TextFormField(
                              obscureText: true,
                              maxLines: 1,
                              decoration: const InputDecoration(
                                icon: Icon(Icons.kitchen),
                                hintText: 'Password',
                                labelText: 'Password *',
                              ),
                              controller: passWordController,
                            ),
                            Padding(
                              padding: EdgeInsets.all(10),
                            ),
                            RaisedButton(
                                color: Theme.of(context).primaryColor,
                                child: Text(
                                  'Login',
                                ),
                                onPressed: () {
                                  if (userNameController.value.text.isEmpty ||
                                      userNameController.value.text.isEmpty)
                                    return;
                                  BotToast.showText(
                                      text: 'Attempting to log in');
                                  BlocProvider.of<LoginBloc>(context).add(
                                      ClickToAuth(
                                          username: userNameController
                                              .value.text
                                              .trim(),
                                          password: passWordController
                                              .value.text
                                              .trim()));
                                }),
                            OutlineButton(
                              child: Text(
                                'Terms',
                              ),
                              onPressed: () async {
                                final url =
                                    'https://www.pixiv.net/terms/?page=term';
                                if (await canLaunch(url)) {
                                  await launch(url);
                                } else {}
                              },
                            ),
                            OutlineButton(
                              child: Text(
                                'Skip',
                              ),
                              onPressed: () async {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        PreviewPage()));
                              },
                            ),
                          ],
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                        ),
                      ),
                    ),
                  ],
                )),
              ),
            ),
          );
        }));
  }
}
