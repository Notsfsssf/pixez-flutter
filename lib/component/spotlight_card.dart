import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pixez/models/spotlight_response.dart';

class SpotlightCard extends StatelessWidget {
  final SpotlightArticle spotlight;

  const SpotlightCard({Key key, this.spotlight}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(4.0),
      child: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: 160.0,
              height: 90.0,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(8.0))),
              child: Align(
                alignment: AlignmentDirectional.bottomCenter,
                child: ListTile(
                    title: Text(
                      spotlight.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      spotlight.pureTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )),
              ),
            ),
          ),
          Card(
            elevation: 8.0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16.0))),
            child: Container(
              child: CachedNetworkImage(
                imageUrl: spotlight.thumbnail,
                httpHeaders: {
                  "referer": "https://app-api.pixiv.net/",
                  "User-Agent": "PixivIOSApp/5.8.0"
                },
                fit: BoxFit.cover,
                height: 150.0,
                width: 150.0,
              ),
              height: 150.0,
              width: 150.0,
            ),
            clipBehavior: Clip.antiAlias,
          )
        ],
      ),
    );
  }
}
