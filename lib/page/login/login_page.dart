import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pixez/generated/i18n.dart';
import 'package:pixez/page/login/bloc/bloc.dart';
import 'package:pixez/page/login/bloc/login_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/login_event.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController userNameController, passWordController;
  @override
  void initState() {
    super.initState();
    userNameController = TextEditingController(text: "userbay");
    passWordController = TextEditingController(text: "userpay");
  }

  @override
  Widget build(BuildContext context1) {
  return  BlocProvider(
    builder: (context)=>LoginBloc(),
    child: BlocListener<LoginBloc,LoginState>(
        listener: (context, state) {
          if (state is SuccessState) {
/*            Scaffold.of(context1).showSnackBar(
              SnackBar(
                backgroundColor: Colors.yellow,
                content: Text(I18n.of(context1).Login),
              ),
            );*/
            Navigator.of(context1).pushNamed('/');
          } else if(state is FailState){
            Scaffold.of(context1).showSnackBar(
              SnackBar(
                backgroundColor: Colors.red,
                content: Text(state.failMessage),
              ),
            );
          }
        },
        child:  Builder(builder: (context){
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
                                style: TextStyle(color: Colors.white),
                              ),
                              onPressed: () => BlocProvider.of<LoginBloc>(context).add(ClickToAuth(username: userNameController.value.text,password: passWordController.value.text)),
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
        })
    ),
  );
  }
}
