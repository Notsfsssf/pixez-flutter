import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixez/component/painter_avatar.dart';
import 'package:pixez/generated/i18n.dart';
import 'package:pixez/page/user/bloc/bloc.dart';
import 'package:pixez/page/user/bloc/user_bloc.dart';
import 'package:pixez/page/user/bookmark/bookmark_page.dart';
import 'package:pixez/page/user/detail/user_detail.dart';
import 'package:pixez/page/user/works/works_page.dart';
import 'package:share/share.dart';

class UserPage extends StatefulWidget {
  final int id;

  UserPage({Key key, this.id}) : super(key: key);

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _tabController.index = index;
    });
  }

  PersistentBottomSheetController controller;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UserBloc()..add(FetchEvent(widget.id)),
      child: BlocBuilder<UserBloc, UserState>(
        condition: (pre, now) {
          return now is! ShowSheetState;
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              actions: <Widget>[
                IconButton(
                    icon: Icon(Icons.share),
                    onPressed: () {
                      if (state is UserDataState)
                        Share.share(
                            'https://www.pixiv.net/member.php?id=${state.userDetail.user.id}');
                    })
              ],
              title: Text(state is UserDataState
                  ? state.userDetail.user.name
                  : widget.id.toString()),
            ),
            body: BlocListener<UserBloc, UserState>(
                condition: (pre, now) {
                  return now is ShowSheetState;
                },
                listener: (context, state) async {
                  if (state is ShowSheetState) {
                    controller = showBottomSheet(
                      context: context,
                      builder: (BuildContext context) {
                        return Container();
                      },
                    );
                  }
                },
                child: _buildTabBarView()),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                    icon: Icon(Icons.work),
                    title: Text(I18n.of(context).Works)),
                BottomNavigationBarItem(
                    icon: Icon(Icons.bookmark), title: Text("Detail")),
                BottomNavigationBarItem(
                    icon: Icon(Icons.bookmark),
                    title: Text(I18n.of(context).BookMark)),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {},
              child: state is UserDataState
                  ? PainterAvatar(
                      url: state.userDetail.user.profile_image_urls.medium,
                      id: state.userDetail.user.id,
                      onTap: () async {
                        BlocProvider.of<UserBloc>(context)
                            .add(ShowSheetEvent());
                      },
                    )
                  : Icon(Icons.data_usage),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
          );
        },
      ),
    );
  }

  TabBarView _buildTabBarView() {
    return TabBarView(
      controller: _tabController,
      children: <Widget>[
        WorksPage(id: widget.id),
        UserDetailPage(),
        BookmarkPage(id: widget.id),
      ],
    );
  }
}
