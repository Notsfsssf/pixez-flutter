import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixez/bloc/bloc.dart';

class SplashPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocListener<AccountBloc, AccountState>(
        listener: (_, state) {
          if (state is NoneUserState) {
            Navigator.pushReplacementNamed(context, '/login');
          }
          if (state is HasUserState) {
            Navigator.pushReplacementNamed(context, '/hello');
          }
        },
        child: Scaffold(
          body: Container(),
        ));
  }
}
