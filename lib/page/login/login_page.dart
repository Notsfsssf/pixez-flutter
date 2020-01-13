import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixez/bloc/account_bloc.dart';
import 'package:pixez/bloc/account_event.dart';
import 'package:pixez/models/create_user_response.dart';
import 'package:pixez/network/oauth_client.dart';
import 'package:pixez/page/create/user/create_user_page.dart';
import 'package:pixez/page/login/bloc/bloc.dart';
import 'package:pixez/page/login/bloc/login_bloc.dart';

import 'bloc/login_event.dart';

class LoginPage extends StatelessWidget {
  TextEditingController userNameController, passWordController;

  @override
  Widget build(BuildContext context) {
    userNameController = TextEditingController(text: "");
    passWordController = TextEditingController(text: "");
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
            body: BlocListener<LoginBloc, LoginState>(
              listener: (context, state) {
                if (state is SuccessState) {
                  BlocProvider.of<AccountBloc>(context)
                      .add(FetchDataBaseEvent());
                  Navigator.of(context).pushReplacementNamed('/hello');
                } else if (state is FailState) {
                  Scaffold.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.red,
                      content: Text(state.failMessage),
                    ),
                  );
                }
              },
              child: SingleChildScrollView(
                  child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(80),
                  ),
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Container(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        children: <Widget>[
                          TextFormField(
                            maxLines: 1,
                            decoration: const InputDecoration(
                              icon: Icon(Icons.supervised_user_circle),
                              hintText: 'Pixiv id/Email',
                              labelText: 'UserName *',
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
                            onPressed: () => BlocProvider.of<LoginBloc>(context)
                                .add(ClickToAuth(
                                    username:
                                        userNameController.value.text.trim(),
                                    password:
                                        passWordController.value.text.trim())),
                          )
                        ],
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                      ),
                    ),
                  ),
                ],
              )),
            ),
          );
        }));
  }
}
