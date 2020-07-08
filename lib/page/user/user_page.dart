/*
 * Copyright (C) 2020. by perol_notsf, All rights reserved
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program. If not, see <http://www.gnu.org/licenses/>.
 *
 */

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixez/bloc/bloc.dart';
import 'package:pixez/component/fab_bottom_appbar.dart';
import 'package:pixez/component/painter_avatar.dart';
import 'package:pixez/generated/i18n.dart';
import 'package:pixez/models/user_detail.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/hello/new/new_page.dart';
import 'package:pixez/page/shield/shield_page.dart';
import 'package:pixez/page/user/bloc/bloc.dart';
import 'package:pixez/page/user/bloc/user_bloc.dart';
import 'package:pixez/page/user/bookmark/bloc.dart';
import 'package:pixez/page/user/bookmark/bookmark_page.dart';
import 'package:pixez/page/user/detail/user_detail.dart';
import 'package:pixez/page/user/works/works_bloc.dart';
import 'package:pixez/page/user/works/works_event.dart';
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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MuteBloc, MuteState>(builder: (context, snapshot) {
      if (snapshot is DataMuteState) {
        for (var i in snapshot.banUserIds) {
          if (i.userId == widget.id.toString())
            return Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0.0,
              ),
              extendBodyBehindAppBar: true,
              extendBody: true,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text('X_X'),
                    RaisedButton(
                      child: Text(I18n.of(context).Shielding_settings),
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) => ShieldPage()));
                      },
                    )
                  ],
                ),
              ),
            );
        }
      }
      return MultiBlocProvider(
        providers: <BlocProvider>[
          BlocProvider<UserBloc>(
            create: (context) =>
                UserBloc(apiClient)..add(FetchEvent(widget.id)),
          ),
          BlocProvider<BookmarkBloc>(
            create: (context) => BookmarkBloc(apiClient, null),
          ),
          BlocProvider<WorksBloc>(
            create: (context) => WorksBloc(apiClient),
          )
        ],
        child: BlocBuilder<UserBloc, UserState>(
          builder: (context, state) {
            if (state is FZFState) {
              return Scaffold(
                appBar: AppBar(
                  title: Text("404"),
                ),
                body: Center(
                  child: Text(
                    '>_<',
                    style: TextStyle(fontSize: 26),
                  ),
                ),
              );
            }
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
                        iconData: Icons.star, text: I18n.of(context).Follow),
                    FABBottomAppBarItem(
                        iconData: Icons.info, text: I18n.of(context).Detail),
                  ],
                  followWidget: state is UserDataState
                      ? _buildFollowButton(
                          context, state.userDetail, state.choiceRestrict)
                      : Container(
                          height: 60.0,
                        ),
                ),
                floatingActionButton: FloatingActionButton(
                  heroTag: widget.id,
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
    });
  }

  Widget _buildFollowButton(context, UserDetail userDetail, String restrict) {
    return BlocBuilder<AccountBloc, AccountState>(
      builder: (context, state) {
        if (state is HasUserState) {
          if (userDetail.user.id == int.parse(state.list.userId))
            return Expanded(
              child: SizedBox(
                height: 60.0,
                child: Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.donut_large,
                          color: Colors.grey,
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          else {
            return Expanded(
              child: SizedBox(
                height: 60.0,
                child: Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    onTap: () {
                      BlocProvider.of<UserBloc>(context)
                          .add(FollowUserEvent(userDetail, restrict, "public"));
                    },
                    onLongPress: () {
                      Scaffold.of(context).showSnackBar(SnackBar(
                        content: Text("Private"),
                      ));
                      BlocProvider.of<UserBloc>(context).add(
                          FollowUserEvent(userDetail, restrict, "private"));
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          userDetail.user.is_followed
                              ? Icons.star
                              : Icons.star_border,
                          color: userDetail.user.is_followed
                              ? Colors.yellow
                              : Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
        } else
          return Container(
            height: 60,
          );
      },
    );
  }

  List<Widget> _buildActions(
      BuildContext context, UserDataState state, AccountState snapshot) {
    if (snapshot is HasUserState) {
      if (int.parse(snapshot.list.userId) != widget.id) {
        return <Widget>[
          IconButton(
            icon: Icon(Icons.brightness_auto),
            onPressed: () async {
              final result = await showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text("Shield?"),
                      actions: <Widget>[
                        FlatButton(
                          child: Text("OK"),
                          onPressed: () {
                            Navigator.of(context).pop("OK");
                          },
                        ),
                        FlatButton(
                          child: Text("CANCEL"),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        )
                      ],
                    );
                  });
              if (result == "OK") {
                if (state is UserDataState)
                  BlocProvider.of<MuteBloc>(context).add(InsertBanUserEvent(
                      widget.id.toString(), state.userDetail.user.name));
              }
            },
          ),
          IconButton(
              icon: Icon(Icons.share),
              onPressed: () {
                if (state is UserDataState)
                  Share.share(
                      'https://www.pixiv.net/users/${state.userDetail.user.id}');
              }),
          PopupMenuButton<WhyFarther>(
            initialValue: WhyFarther.public,
            onSelected: (WhyFarther result) {
              if (WhyFarther.public == result) {
                BlocProvider.of<WorksBloc>(context)
                    .add(FetchWorksEvent(widget.id, "illust"));
              } else if (WhyFarther.private == result) {
                BlocProvider.of<WorksBloc>(context)
                    .add(FetchWorksEvent(widget.id, "manga"));
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<WhyFarther>>[
              PopupMenuItem<WhyFarther>(
                value: WhyFarther.public,
                child: Text(I18n.of(context).Illust),
              ),
              PopupMenuItem<WhyFarther>(
                value: WhyFarther.private,
                child: Text('manga'),
              ),
            ],
          )
        ];
      }
    }

    if (_selectedIndex != 1)
      return <Widget>[
        IconButton(
          icon: Icon(Icons.brightness_auto),
          onPressed: () async {
            final result = await showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text("Shield?"),
                    actions: <Widget>[
                      FlatButton(
                        child: Text("OK"),
                        onPressed: () {
                          Navigator.of(context).pop("OK");
                        },
                      )
                    ],
                  );
                });
            if (result == "OK") {
              if (state is UserDataState)
                BlocProvider.of<MuteBloc>(context).add(InsertBanUserEvent(
                    widget.id.toString(), state.userDetail.user.name));
            }
          },
        ),
        IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              if (state is UserDataState)
                Share.share(
                    'https://www.pixiv.net/users/${state.userDetail.user.id}');
            })
      ];
    else
      return <Widget>[
        IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              if (state is UserDataState)
                Share.share(
                    'https://www.pixiv.net/users/${state.userDetail.user.id}');
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
        UserDetailPage(
          userDetail: state.userDetail,
        ),
      ],
    );
  }
}
