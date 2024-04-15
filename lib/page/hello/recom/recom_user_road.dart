import 'package:flutter/material.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/page/hello/recom/recom_user_page.dart';
import 'package:pixez/page/hello/recom/recom_user_store.dart';

class RecomUserRoad extends StatefulWidget {
  final RecomUserStore? recomUserStore;

  const RecomUserRoad({Key? key, this.recomUserStore}) : super(key: key);

  @override
  _RecomUserRoadState createState() => _RecomUserRoadState();
}

class _RecomUserRoadState extends State<RecomUserRoad> {
  late RecomUserStore _recomUserStore;

  @override
  void initState() {
    _recomUserStore = widget.recomUserStore ?? RecomUserStore(null)
      ..fetch();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return RecomUserPage(
            recomUserStore: _recomUserStore,
          );
        }));
      },
      child: Container(
        height: 60,
        margin: EdgeInsets.only(left: 20),
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 40,
                margin: EdgeInsets.only(left: 8.0),
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
                          return _buildUserList(index);
                        },
                      )
                    : Container(),
              ),
            )
          ],
        ),
      ),
    );
  }

  Padding _buildUserList(int index) {
    final data = _recomUserStore.users[index];
    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: SizedBox(
        height: 40,
        width: 40,
        child: CircleAvatar(
          backgroundImage: PixivProvider.url(data.user.profileImageUrls.medium,
              preUrl: data.user.profileImageUrls.medium),
          radius: 100.0,
        ),
      ),
    );
  }
}
