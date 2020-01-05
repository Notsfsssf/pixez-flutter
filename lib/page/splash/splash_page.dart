import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixez/bloc/bloc.dart';
import 'package:uni_links/uni_links.dart';

class SplashPage extends StatelessWidget {
  Future<String> initUniLinks() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      String initialLink = await getInitialLink();
      print(initialLink);
      return initialLink;
      // Parse the link and warn the user, if it is not correct,
      // but keep in mind it could be `null`.
    } on PlatformException {
      // Handle exception by warning the user their action did not succeed
      // return?
    }
  }

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
