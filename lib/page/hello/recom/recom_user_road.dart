import 'package:flutter/material.dart';
import 'package:pixez/component/painter_avatar.dart';
import 'package:pixez/page/hello/recom/recom_user_store.dart';

class RecomUserRoad extends StatefulWidget {
  @override
  _RecomUserRoadState createState() => _RecomUserRoadState();
}

class _RecomUserRoadState extends State<RecomUserRoad> {
  RecomUserStore _recomUserStore;
  @override
  void initState() {
    _recomUserStore = RecomUserStore()..fetch();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      child: Stack(
        children: [
          Align(
            child: Text("推荐用户"),
            alignment: Alignment.centerLeft,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              height: 60,
              padding: EdgeInsets.only(
                  left: Theme.of(context).textTheme.bodyText1.fontSize * 4 + 8),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(16.0),
                      topLeft: Radius.circular(16.0)),
                  color: Colors.transparent),
              child: _recomUserStore.users.isNotEmpty
                  ? ListView.builder(
                      itemCount: _recomUserStore.users.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        final data = _recomUserStore.users[index];
                        return Padding(
                          padding: const EdgeInsets.all(1.0),
                          child: PainterAvatar(
                            size: Size(50.0, 50.0),
                            id: data.user.id,
                            url: data.user.profileImageUrls.medium,
                          ),
                        );
                      },
                    )
                  : Container(),
            ),
          )
        ],
      ),
    );
  }
}
