import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixez/bloc/bloc.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/generated/i18n.dart';
import 'package:pixez/page/picture/picture_page.dart';

class HistoryPage extends StatelessWidget {
  Widget buildAppBarUI(context) => Container(
        child: Padding(
          child: Text(
            I18n.of(context).History,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30.0),
          ),
          padding: EdgeInsets.only(left: 20.0, top: 30.0, bottom: 30.0),
        ),
      );

  Widget buildBody() => BlocBuilder<IllustPersistBloc, IllustPersistState>(
          builder: (context, state) {
        if (state is DataIllustPersistState)
        {
          var reIllust = state.illusts.reversed.toList();
          return GridView.builder(
              itemCount: reIllust.length,
              gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
              itemBuilder: (context, index) {
                return GestureDetector(
                    onTap: () {
                      Navigator.of(context,rootNavigator: true).push(
                          MaterialPageRoute(builder: (BuildContext context) {
                            return PicturePage(null,reIllust[index].illustId);
                          }));
                    },
                    onLongPress: () async {
                      final result = await showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text("${I18n.of(context).Delete}?"),
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
                        BlocProvider.of<IllustPersistBloc>(context).add(
                            DeleteIllustPersistEvent(reIllust[index].illustId));
                      }
                    },
                    child: Card(
                        margin: EdgeInsets.all(8.0),
                        child: PixivImage(reIllust[index].pictureUrl)));
              });
        }
        else
          return Center(
            child: CircularProgressIndicator(),
          );
      });

  @override
  Widget build(BuildContext context) {
    BlocProvider.of<IllustPersistBloc>(context).add(FetchIllustPersistEvent());
    return Scaffold(
      appBar: AppBar(
        title: Text("History"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.clear_all),
            onPressed: () async {
              final result = await showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text("${I18n.of(context).Delete} All?"),
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
                    .add(DeleteAllIllustPersistEvent());
              }
            },
          )
        ],
      ),
      body: buildBody(),
    );
  }
}
