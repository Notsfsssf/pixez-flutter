import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/page/user/user_page.dart';

class PainterAvatar extends StatefulWidget {
  final String url;
  final int id;
  const PainterAvatar({Key key, this.url, this.id}) : super(key: key);
  @override
  _PainterAvatarState createState() => _PainterAvatarState();
}

class _PainterAvatarState extends State<PainterAvatar> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) {
          return UserPage(
            id: widget.id
          );
        }));
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
