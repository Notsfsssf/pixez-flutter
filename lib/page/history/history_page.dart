import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixez/bloc/bloc.dart';

import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/generated/i18n.dart';
import 'package:pixez/page/picture/picture_page.dart';

class HistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
   BlocProvider.of<IllustPersistBloc>(context).add(FetchIllustPersistEvent());
    return Scaffold(
        appBar: AppBar(
          title: Text(I18n.of(context).History),
        ),
        body: BlocBuilder<IllustPersistBloc, IllustPersistState>(
          builder: (context, state) {
            if (state is DataIllustPersistState)
              return Container(
                child: GridView.builder(
                    itemCount: state.illusts.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2),
                    itemBuilder: (context, index) {
                      return GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (BuildContext context) {
                              return PicturePage(
                                  null, state.illusts[index].illustId);
                            }));
                          },
                          onLongPress: () async {
                            final result = await showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text("Delete?"),
                                    actions: <Widget>[
                                      FlatButton(
                                        child: Text("OK"),
                                        onPressed: () {
                                          Navigator.of(context).pop("OK");
                                        },
                                      )
                                    ],
                                  );
                                });
                            if (result == "OK") {
                              BlocProvider.of<IllustPersistBloc>(context)
                                  .add(DeleteIllustPersistEvent(
                                      state.illusts[index].illustId));
                            }
                          },
                          child: Card(
                              child: PixivImage(
                                  state.illusts[index].pictureUrl)));
                    }),
              );
            else
              return Center(
                child: CircularProgressIndicator(),
              );
          },
        ));
  }
}
