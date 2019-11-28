import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixez/component/painter_avatar.dart';
import 'package:pixez/page/user/bloc/bloc.dart';
import 'package:pixez/page/user/bloc/user_bloc.dart';
import 'package:pixez/page/user/bookmark/bookmark_page.dart';
import 'package:pixez/page/user/works/works_page.dart';

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
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
                  PainterAvatar(
                    url: user.profile_image_urls.medium,
                    id: user.id,
                  )
                ],
                title: Text(user.name),
                bottom: TabBar(
                  controller: _tabController,
                  tabs: <Widget>[
                    Tab(text: 'LEFT'),
                    Tab(text: 'RIGHT'),
                  ],
                ),
              ),
              body: TabBarView(
                controller: _tabController,
                children: <Widget>[
                  WorksPage(id: widget.id),
                  BookmarkPage(id: widget.id),
                ],
              ),
            );
          }
          return Container();
        },
      ),
    );
  }
}
