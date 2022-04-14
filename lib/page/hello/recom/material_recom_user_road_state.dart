import 'package:flutter/material.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/page/hello/recom/recom_user_page.dart';
import 'package:pixez/page/hello/recom/recom_user_road.dart';
import 'package:pixez/page/hello/recom/recom_user_store.dart';

class MaterialRecomUserRoadState extends RecomUserRoadStateBase {
  late RecomUserStore recomUserStore;

  @override
  void initState() {
    recomUserStore = widget.recomUserStore ?? RecomUserStore()
      ..fetch();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return RecomUserPage(
            recomUserStore: recomUserStore,
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
                child: recomUserStore.users.isNotEmpty
                    ? ListView.builder(
                        itemCount: recomUserStore.users.length,
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
    final data = recomUserStore.users[index];
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

