import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixez/bloc/bloc.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/network/oauth_client.dart';
import 'package:pixez/network/onezero_client.dart';
import 'package:pixez/page/hello/hello_page.dart';
import 'package:pixez/page/login/login_page.dart';

class SplashPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<OnezeroBloc>(
      child: MultiBlocListener(
        child: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        listeners: <BlocListener>[
          BlocListener<AccountBloc, AccountState>(
            listener: (_, state) {
              if (state is NoneUserState) {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (BuildContext context) => LoginPage()));
              }
            },
          ),
          BlocListener<OnezeroBloc, OnezeroState>(
            listener: (_, state) {
              if (state is DataOnezeroState) {
                var address = state.onezeroResponse.answer.first.data;
                print('address:$address');
                if (address != null && address.isNotEmpty) {
                  RepositoryProvider.of<ApiClient>(context)
                      .httpClient
                      .options
                      .baseUrl = 'https://$address';
                  RepositoryProvider.of<OAuthClient>(context)
                      .httpClient
                      .options
                      .baseUrl = 'https://$address';
                }
                if (BlocProvider.of<AccountBloc>(context).state is HasUserState)
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => HelloPage()));
              } else if (state is FailOnezeroState) {
                if (BlocProvider.of<AccountBloc>(context).state is HasUserState)
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => HelloPage()));
              }
            },
          ),
        ],
      ),
      create: (BuildContext context) {
        return OnezeroBloc(OnezeroClient())..add(FetchOnezeroEvent());
      },
    );
  }
}
