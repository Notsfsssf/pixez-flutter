import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixez/generated/i18n.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/hello/new/painter/bloc/new_painter_bloc.dart';
import 'package:pixez/page/hello/new/painter/new_painter_page.dart';

class FollowPage extends StatelessWidget {
  final int id;

  const FollowPage(
    this.id, {
    Key key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(I18n.of(context).Follow),
      ),
      body: BlocProvider<NewPainterBloc>(
        child: NewPainterPage(
          id: id,
          restrict: 'public',
        ),
        create: (context) =>
            NewPainterBloc(RepositoryProvider.of<ApiClient>(context)),
      ),
    );
  }
}
