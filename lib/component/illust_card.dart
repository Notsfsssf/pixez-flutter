import 'package:flutter/material.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/models/illust.dart';

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
      onTap: () => {},
      child: Card(
        child: PixivImage(widget._illusts.imageUrls.medium),
      ),
    );
  }
}
