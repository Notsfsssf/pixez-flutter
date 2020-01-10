import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixez/bloc/bloc.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/network/oauth_client.dart';
import 'package:pixez/network/onezero_client.dart';

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
                Navigator.pushReplacementNamed(context, '/login');
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
                Navigator.pushReplacementNamed(context, '/hello');
              } else if (state is FailOnezeroState) {
                Navigator.pushReplacementNamed(context, '/hello');
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
