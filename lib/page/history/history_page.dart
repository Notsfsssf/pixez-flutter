import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixez/bloc/bloc.dart';
import 'package:pixez/bloc/history_persist_bloc.dart';
import 'package:pixez/generated/i18n.dart';

class HistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bloc =BlocProvider.of<HistoryPersistBloc>(context);
    bloc.add(FetchHistoryPersistEvent());
    return Scaffold(
      appBar: AppBar(
        title: Text(I18n.of(context).History),
      ),
      body: BlocBuilder<HistoryPersistBloc, HistoryPersistState>(
        builder: (context, state) {
          return Container();
        },
      ),
    );;
  }
}