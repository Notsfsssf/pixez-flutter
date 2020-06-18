import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/page/user/users_page.dart';

class PainterAvatar extends StatefulWidget {
  final String url;
  final int id;
  final GestureTapCallback onTap;
  final Size size;

  const PainterAvatar({Key key, this.url, this.id, this.onTap, this.size})
      : super(key: key);

  @override
  _PainterAvatarState createState() => _PainterAvatarState();
}

class _PainterAvatarState extends State<PainterAvatar> {
  void pushToUserPage() {
    Navigator.of(context, rootNavigator: true)
        .push(MaterialPageRoute(builder: (_) {
      return UsersPage(id: widget.id);
    }));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          if (widget.onTap == null) {
            pushToUserPage();
          } else
            widget.onTap();
        },
        child: widget.size == null
            ? SizedBox(
                height: 60,
                width: 60,
                child: CircleAvatar(
                  backgroundImage: PixivProvider.url(
                    widget.url,
                  ),
                  radius: 100.0,
                ),
              )
            : SizedBox(
                height: widget.size.height,
                width: widget.size.width,
                child: CircleAvatar(
                  backgroundImage: PixivProvider.url(
                    widget.url,
                  ),
                  radius: 100.0,
                ),
              ));
  }
}
