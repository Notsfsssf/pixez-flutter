import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixez/page/login/bloc/bloc.dart';
import 'package:pixez/page/login/bloc/login_bloc.dart';

import 'bloc/login_event.dart';

class LoginPage extends StatelessWidget {
  TextEditingController userNameController, passWordController;

  @override
  Widget build(BuildContext context1) {
    userNameController = TextEditingController(text: "userbay");
    passWordController = TextEditingController(text: "userpay");
    return BlocProvider(
      create: (context) => LoginBloc(),
      child: BlocListener<LoginBloc, LoginState>(listener: (context, state) {
        if (state is SuccessState) {
          Navigator.of(context1).pushReplacementNamed('/hello');
        } else if (state is FailState) {
          Scaffold.of(context1).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text(state.failMessage),
            ),
          );
        }
      }, child: Builder(builder: (context) {
        return Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () async {},
            child: Icon(Icons.arrow_forward),
          ),
          body: SingleChildScrollView(
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
                        decoration: const InputDecoration(
                          icon: Icon(Icons.home),
                          hintText: 'Name',
                          labelText: 'Hello *',
                        ),
                        controller: userNameController,
                      ),
                      Padding(
                        padding: EdgeInsets.all(10),
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          icon: Icon(Icons.home),
                          hintText: 'Password',
                          labelText: 'Password *',
                        ),
                        controller: passWordController,
                      ),
                      Padding(
                        padding: EdgeInsets.all(10),
                      ),
                      RaisedButton(
                        child: Text(
                          'Login',
                        ),
                        onPressed: () => BlocProvider.of<LoginBloc>(context)
                            .add(ClickToAuth(
                                username: userNameController.value.text,
                                password: passWordController.value.text)),
                      )
                    ],
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                  ),
                ),
              ),
            ],
          )),
        );
      })),
    );
  }

}

