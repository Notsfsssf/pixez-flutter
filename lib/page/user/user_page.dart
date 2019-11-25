import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pixez/page/user/bloc/bloc.dart';
import 'package:pixez/page/user/bloc/user_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserPage extends StatefulWidget {
  final int id;

  UserPage({Key key, this.id}) : super(key: key);
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      builder: (context) => UserBloc()..add(FetchEvent(widget.id)),
      child: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          return Scaffold(
            body: Container(
              child: TextField(),
            ),
          );
        },
      ),
    );
  }
}
