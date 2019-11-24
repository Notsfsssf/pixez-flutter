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
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => {
        Navigator.of(context).push(MaterialPageRoute(builder: (_){
          return PicturePage(widget._illusts);
        }))
      },
      child: Card(
        child: PixivImage(widget._illusts.imageUrls.medium),
      ),
    );
  }
}
