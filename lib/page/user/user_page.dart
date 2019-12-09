import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixez/component/painter_avatar.dart';
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

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      builder: (context) => UserBloc()..add(FetchEvent(widget.id)),
      child: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          if (state is UserDataState) {
            final user = state.userDetail.user;
            return Scaffold(
              appBar: AppBar(
                actions: <Widget>[
                  IconButton(
                      icon: Icon(Icons.share),
                      onPressed: () {
                        Share.share(
                            'https://www.pixiv.net/member.php?id=${state.userDetail.user.id}');
                      })
                ],
                title: Text(user.name),
              ),
              body: _buildTabBarView(),
              bottomNavigationBar: BottomNavigationBar(
                currentIndex: _selectedIndex,
                onTap: _onItemTapped,
                items: <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                      icon: Icon(Icons.work), title: Text("Work")),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.bookmark), title: Text("Detail")),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.bookmark), title: Text("Book")),
                ],
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () {},
                child: PainterAvatar(
                  url: user.profile_image_urls.medium,
                  id: user.id,
                  onTap: () {},
                ),
                shape: const CircleBorder(),
              ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerDocked,
            );
          }
          return Scaffold();
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
