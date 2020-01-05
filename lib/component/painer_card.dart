import 'package:flutter/material.dart';
import 'package:pixez/component/painter_avatar.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/models/user_preview.dart';
import 'package:pixez/page/user/user_page.dart';

class PainterCard extends StatelessWidget {
  final UserPreviews user;

  const PainterCard({Key key, this.user}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (BuildContext context) {
          return UserPage(
            id: user.user.id,
          );
        }));
      },
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            GridView.count(
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              children: user.illusts
                  .map((f) => PixivImage(f.imageUrls.squareMedium))
                  .toList(),
              shrinkWrap: true,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  PainterAvatar(
                      url: user.user.profileImageUrls.medium, id: user.user.id),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(user.user.name),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
