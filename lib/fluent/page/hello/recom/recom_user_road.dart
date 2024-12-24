import 'package:fluent_ui/fluent_ui.dart';
import 'package:pixez/fluent/component/pixiv_image.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/fluent/page/hello/recom/recom_user_page.dart';
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
    return Container(
      height: 60,
      margin: EdgeInsets.only(left: 20),
      child: ButtonTheme(
        data: ButtonThemeData(
          iconButtonStyle: ButtonStyle(
            padding: WidgetStateProperty.all(EdgeInsets.zero),
          ),
        ),
        child: IconButton(
          onPressed: () {
            Leader.push(
              context,
              RecomUserPage(recomUserStore: _recomUserStore),
              icon: Icon(FluentIcons.account_browser),
              title: Text(I18n.of(context).recommend_for_you),
            );
          },
          icon: Row(
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
