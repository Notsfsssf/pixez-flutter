import 'package:flutter/material.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/models/illust.dart';
import 'package:pixez/page/picture/picture_page.dart';

class IllustCard extends StatefulWidget {
  Illusts _illusts;

  IllustCard(this._illusts);

  @override
  _IllustCardState createState() => _IllustCardState();
}

class _IllustCardState extends State<IllustCard> {
  Widget cardText() {
    if (widget._illusts.type != "illust") {
      return Text(widget._illusts.type);
    }
    if (widget._illusts.metaPages.isNotEmpty) {
      return Text(widget._illusts.metaPages.length.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) {
          return PicturePage(widget._illusts,widget._illusts.id);
        }))
      },
      child: Hero(
        child: Card(
          child: Stack(
            children: <Widget>[
              PixivImage(widget._illusts.imageUrls.medium),
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Container(

                    child: cardText(),
                    color: Colors.black12,
                  ),
                ),
              )
            ],
          ),
        ),
        tag: widget._illusts.imageUrls.medium,
      ),
    );
  }
}
