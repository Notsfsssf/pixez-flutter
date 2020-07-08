import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/page/picture/illust_about_store.dart';
import 'package:pixez/page/picture/illust_page.dart';
class IllustAboutGrid extends StatefulWidget {
    final int id;

  const IllustAboutGrid({Key key, this.id}) : super(key: key);
  @override
  _IllustAboutGridState createState() => _IllustAboutGridState();
}

class _IllustAboutGridState extends State<IllustAboutGrid> {
  IllustAboutStore _store;
  @override
  void initState() {
   _store = IllustAboutStore(widget.id)..fetch();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      if (_store.errorMessage != null) {
        return Container(
          height: 300,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(':(', style: Theme.of(context).textTheme.headline4),
              ),
              RaisedButton(
                onPressed: () {
                  _store.fetch();
                },
                child: Text('Refresh'),
              )
            ],
          ),
        );
      }
      if (_store.illusts.isNotEmpty)
        return GridView.builder(
            padding: EdgeInsets.all(0.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, //
            ),
            shrinkWrap: true,
            itemCount: _store.illusts.length,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (BuildContext context) {
                    return IllustPage(
                      id: _store.illusts[index].id,
                    );
                  }));
                },
                child: PixivImage(_store.illusts[index].imageUrls.squareMedium),
              );
            });
      return Center(
        child: CircularProgressIndicator(),
      );
    });
 
  }
}

