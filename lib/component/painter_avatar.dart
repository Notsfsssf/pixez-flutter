import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/page/user/user_page.dart';

class PainterAvatar extends StatefulWidget {
  final String url;
  final int id;
  final GestureTapCallback onTap;

  const PainterAvatar({Key key, this.url, this.id, this.onTap})
      : super(key: key);

  @override
  _PainterAvatarState createState() => _PainterAvatarState();
}

class _PainterAvatarState extends State<PainterAvatar> {
  void pushToUserPage() {
    Navigator.of(context, rootNavigator: true)
        .push(MaterialPageRoute(builder: (_) {
      return UserPage(id: widget.id);
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
      child: SizedBox(
        height: 60,
        width: 60,
        child: CircleAvatar(
          backgroundImage: PixivProvider(
            widget.url,
          ),
          radius: 100.0,
        ),
      ),
    );
  }
}
