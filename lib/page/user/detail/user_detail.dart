import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixez/page/user/bloc/bloc.dart';

class UserDetailPage extends StatefulWidget {
  @override
  _UserDetailPageState createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: BlocProvider.of<UserBloc>(context),
      builder: (context, state) {
        if (state is UserDataState)
          return Container(
            child: Text(state.userDetail.user.name),
          );
        else
          return Center(
            child: CircularProgressIndicator(),
          );
      },
    );
  }
}
