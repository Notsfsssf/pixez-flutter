import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixez/bloc/bloc.dart';
import 'package:pixez/component/fab_bottom_appbar.dart';
import 'package:pixez/component/painter_avatar.dart';
import 'package:pixez/generated/i18n.dart';
import 'package:pixez/page/hello/new/new_page.dart';
import 'package:pixez/page/user/bloc/bloc.dart';
import 'package:pixez/page/user/bloc/user_bloc.dart';
import 'package:pixez/page/user/bookmark/bloc.dart';
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
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedIndex = this._tabController.index;
      });
    });
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
    return MultiBlocProvider(
      providers: <BlocProvider>[
        BlocProvider<UserBloc>(
          create: (context) => UserBloc()..add(FetchEvent(widget.id)),
        ),
        BlocProvider<BookmarkBloc>(
          create: (context) => BookmarkBloc(),
        )
      ],
      child: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          return BlocBuilder<AccountBloc, AccountState>(
              builder: (context, snapshot) {
            return Scaffold(
              extendBody: true,
              appBar: state is UserDataState
                  ? AppBar(
                      actions: _buildActions(context, state, snapshot),
                      title: Text(state.userDetail.user.name),
                    )
                  : AppBar(),
              body: state is UserDataState
                  ? _buildTabBarView(context, state)
                  : Center(
                      child: CircularProgressIndicator(),
                    ),
              bottomNavigationBar: FABBottomAppBar(
                onTabSelected: (index) {
                  _tabController.index = index;
                },
                color: Colors.grey,
                selectedColor: Theme.of(context).primaryColor,
                centerItemText: "A",
                notchedShape: CircularNotchedRectangle(),
                items: [
                  FABBottomAppBarItem(
                      iconData: Icons.menu, text: I18n.of(context).Works),
                  FABBottomAppBarItem(
                      iconData: Icons.bookmark,
                      text: I18n.of(context).BookMark),
                  FABBottomAppBarItem(
                      iconData: Icons.star, text:I18n.of(context).Follow),
                  FABBottomAppBarItem(iconData: Icons.info, text: I18n.of(context).Detail),
                ],
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () {},
                child: state is UserDataState
                    ? PainterAvatar(
                        url: state.userDetail.user.profile_image_urls.medium,
                        id: state.userDetail.user.id,
                        onTap: () async {},
                      )
                    : Icon(Icons.refresh),
              ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerDocked,
            );
          });
        },
      ),
    );
  }

  List<Widget> _buildActions(
      BuildContext context, UserDataState state, AccountState snapshot) {
    if (snapshot is HasUserState) {
      if (int.parse(snapshot.list.userId) != widget.id) {
        return <Widget>[
          IconButton(
              icon: Icon(Icons.share),
              onPressed: () {
                if (state is UserDataState)
                  Share.share(
                      'https://www.pixiv.net/member.php?id=${state.userDetail.user.id}');
              })
        ];
      }
    }

    if (_selectedIndex != 1)
      return <Widget>[
        IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              if (state is UserDataState)
                Share.share(
                    'https://www.pixiv.net/member.php?id=${state.userDetail.user
                        .id}');
            })
      ];
    else
      return <Widget>[
        IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              if (state is UserDataState)
                Share.share(
                    'https://www.pixiv.net/member.php?id=${state.userDetail.user.id}');
            }),
        PopupMenuButton<WhyFarther>(
          initialValue: WhyFarther.public,
          onSelected: (WhyFarther result) {
            if (WhyFarther.public == result) {
              BlocProvider.of<UserBloc>(context)
                  .add(ChoiceRestrictEvent("public", state.userDetail));
            } else if (WhyFarther.private == result) {
              BlocProvider.of<UserBloc>(context)
                  .add(ChoiceRestrictEvent("private", state.userDetail));
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<WhyFarther>>[
            PopupMenuItem<WhyFarther>(
              value: WhyFarther.public,
              child: Text(I18n.of(context).Public),
            ),
            PopupMenuItem<WhyFarther>(
              value: WhyFarther.private,
              child: Text(I18n.of(context).Private),
            ),
          ],
        )
      ];
  }

  TabBarView _buildTabBarView(BuildContext context, UserDataState state) {
    return TabBarView(
      controller: _tabController,
      children: <Widget>[
        WorksPage(id: widget.id),
        BlocListener<UserBloc, UserState>(
            listener: (context, state) {
              if (state is UserDataState) {
                BlocProvider.of<BookmarkBloc>(context)
                    .add(FetchBookmarkEvent(widget.id, state.choiceRestrict));
              }
            },
            child: BookmarkPage(
              id: widget.id,
              restrict: state.choiceRestrict,
            )),
        Container(),
        UserDetailPage(),
      ],
    );
  }
}
