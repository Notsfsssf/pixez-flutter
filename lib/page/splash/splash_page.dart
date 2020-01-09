import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixez/bloc/bloc.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/network/oauth_client.dart';

class SplashPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      child: Scaffold(
        body: Container(),
      ),
      listeners: <BlocListener>[
        BlocListener<AccountBloc, AccountState>(
          listener: (_, state) {
            if (state is NoneUserState) {
              Navigator.pushReplacementNamed(context, '/login');
            }
            if (state is HasUserState) {
              Navigator.pushReplacementNamed(context, '/hello');
            }
          },
        ),
        BlocListener<OnezeroBloc, OnezeroState>(
          listener: (_, state) {
            if (state is DataOnezeroState) {
              var address = state.onezeroResponse.answer.first.data;
              print('address:$address');
              RepositoryProvider.of<ApiClient>(context).httpClient.options.baseUrl='https://$address';
              RepositoryProvider.of<OAuthClient>(context).httpClient.options.baseUrl='https://$address';
            }
          },
        ),
      ],
    );
  }
}
