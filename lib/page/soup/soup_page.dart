import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixez/page/soup/bloc.dart';

class SoupPage extends StatefulWidget {
  final String url;

  SoupPage({Key key, this.url}) : super(key: key);

  @override
  _SoupPageState createState() => _SoupPageState();
}

class _SoupPageState extends State<SoupPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider<SoupBloc>(
        child: BlocBuilder<SoupBloc, SoupState>(builder: (context, snapshot) {
          if (snapshot is DataSoupState) {
            return Container();
          }
          return Container();
        }),
        create: (BuildContext context) =>
            SoupBloc()..add(FetchSoupEvent(widget.url)),
      ),
    );
  }
}
