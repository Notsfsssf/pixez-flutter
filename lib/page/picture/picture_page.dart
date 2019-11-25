import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pixez/component/PainterAvatar.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/models/illust.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixez/page/picture/bloc/bloc.dart';

class AppBarColumn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: new Column(
        children: <Widget>[
          new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              new IconButton(
                icon: new Icon(
                  Icons.arrow_back,
                  color: Colors.black54,
                ),
                onPressed: () =>
                    Navigator.canPop(context) ? Navigator.pop(context) : null,
              ),
              new IconButton(
                icon: new Icon(
                  Icons.more_vert,
                  color: Colors.black54,
                ),
                onPressed: () {},
              )
            ],
          ),
        ],
      ),
    );
  }
}

class PicturePage extends StatefulWidget {
  final Illusts _illusts;
  PicturePage(this._illusts);
  @override
  _PicturePageState createState() => _PicturePageState();
}

class _PicturePageState extends State<PicturePage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        builder: (context) => PictureBloc(),
        child: BlocBuilder<PictureBloc, PictureState>(
          builder: (context, state) {
            return Scaffold(
              body: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  _buildBody(widget._illusts, context),
                  AppBarColumn()
                ],
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  BlocProvider.of<PictureBloc>(context)
                      .add(StarEvent(widget._illusts));
                },
                child: Icon(Icons.star),
                foregroundColor:
                    widget._illusts.isBookmarked ? Colors.red : Colors.white,
              ),
            );
          },
        ));
  }
}

Widget _buildBody(Illusts illust, BuildContext context) {
  Widget _buildSingleItem(int index) => GestureDetector(
        onLongPress: () {},
        onTap: () {},
        child: index == 0
            ? Hero(
                child: PixivImage(
                  illust.metaPages[index].imageUrls.medium,
                  placeHolder: illust.metaPages[index].imageUrls.large,
                ),
                tag: illust.imageUrls.medium,
              )
            : PixivImage(
                illust.metaPages[index].imageUrls.medium,
                placeHolder: illust.metaPages[index].imageUrls.large,
              ),
      );
  return SingleChildScrollView(
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          illust.metaPages.isNotEmpty
              ? Expanded(
                  child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: illust.metaPages.length,
                      itemBuilder: (BuildContext context, int index) {
                        return _buildSingleItem(index);
                      }),
                )
              : GestureDetector(
                  child: Hero(
                    child: PixivImage(
                      illust.imageUrls.large,
                      placeHolder: illust.imageUrls.medium,
                    ),
                    tag: illust.imageUrls.medium,
                  ),
                  onLongPress: () => {},
                ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                  child: PainterAvatar(url: illust.user.profileImageUrls.medium,id: illust.user.id,),
                  padding: EdgeInsets.all(8.0)),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        illust.title,
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                      Text(illust.user.name),
                      Text(illust.createDate),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Html(
                data: illust.caption.isEmpty ? "~" : illust.caption,
              ),
            ),
          ),
          Wrap(
            spacing: 2, // gap between adjacent chips
            runSpacing: 0, // gap between lines
            children: illust.tags
                .map((f) => ActionChip(
                      label: Text(f.translatedName ?? ""),
                      onPressed: () {},
                    ))
                .toList(),
          )
        ],
      ),
    ),
  );
}
