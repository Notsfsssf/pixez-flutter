import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixez/models/novel_text_response.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/novel/viewer/bloc.dart';

class NovelViewerPage extends StatefulWidget {
  final int id;

  const NovelViewerPage({Key key, @required this.id}) : super(key: key);

  @override
  _NovelViewerPageState createState() => _NovelViewerPageState();
}

class _NovelViewerPageState extends State<NovelViewerPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<NovelTextBloc>(
      child:
          BlocBuilder<NovelTextBloc, NovelTextState>(builder: (context, state) {
        if (state is DataNovelState) {
          var seriesNext = state.novelTextResponse.seriesPrev.seriesNext;
          var seriesPrev = state.novelTextResponse.seriesPrev;
          return Scaffold(
            appBar: AppBar(
              elevation: 0.0,
              backgroundColor: Colors.transparent,
            ),
            extendBody: true,
            extendBodyBehindAppBar: true,
            body: Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top,
                  left: 8.0,
                  right: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SelectableText(state.novelTextResponse.novelText),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      buildListTile(seriesPrev),
                      buildListTile(seriesNext),
                    ],
                  )
                ],
              ),
            ),
          );
        }
        return Scaffold();
      }),
      create: (BuildContext context) => NovelTextBloc(
          RepositoryProvider.of<ApiClient>(context),
          id: widget.id)
        ..add(FetchEvent()),
    );
  }

  ListTile buildListTile(Series series) {
    return ListTile(
      leading: Text(series.title),
      onTap: () {
        Navigator.of(context, rootNavigator: true)
            .pushReplacement(MaterialPageRoute(
                builder: (BuildContext context) => NovelViewerPage(
                      id: series.id,
                    )));
      },
    );
  }
}
