import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
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
        Navigator.of(context, rootNavigator: true)
            .push(MaterialPageRoute(builder: (BuildContext context) {
          return UserPage(
            id: user.user.id,
          );
        }));
      },
      child: Card(
        child: StaggeredGridView.countBuilder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          itemBuilder: (BuildContext context, int index) {
            if (index != 3) {
              if (index < user.illusts.length) {
                return PixivImage(user.illusts[index].imageUrls.squareMedium);
              }
              return Container();
            }
            return buildPadding();
          },
          itemCount: 4,
          staggeredTileBuilder: (int index) =>
              StaggeredTile.fit(index != 3 ? 1 : 3),
        ),
      ),
    );
  }

  Padding buildPadding() {
    return Padding(
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
    );
  }
}
