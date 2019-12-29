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
      return Text(
        widget._illusts.type,
      );
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
      child: Card(
        margin: EdgeInsets.all(8.0),
             elevation: 8.0,  
                     clipBehavior: Clip.antiAlias,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
        child: Column(
          children: <Widget>[
            Hero(
              child: Stack(
                children: <Widget>[
                  PixivImage(widget._illusts.imageUrls.medium),
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Container(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0,
                              horizontal: 2.0),
                          child: cardText(),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.all(Radius.circular(4.0)),
                        ),
                      ),
                    ),
                  )
                ],
              ),
              tag: widget._illusts.imageUrls.medium,
            ),
            ListTile(
              title: Text(widget._illusts.title,maxLines: 2,overflow: TextOverflow.ellipsis,),
              subtitle: Text(widget._illusts.user.name,maxLines: 2,overflow: TextOverflow.ellipsis,),
            )
          ],
        ),
      ),
    );
  }
}
