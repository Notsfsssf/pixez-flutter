import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_easyrefresh/material_header.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/bloc/account_bloc.dart';
import 'package:pixez/bloc/account_state.dart';
import 'package:pixez/component/painer_card.dart';
import 'package:pixez/generated/l10n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/user_preview.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/follow/follow_store.dart';
import 'package:pixez/page/preview/preview_page.dart';

class FollowList extends StatefulWidget {
  final int id;

  const FollowList({Key key, this.id}) : super(key: key);

  @override
  _FollowListState createState() => _FollowListState();
}

class _FollowListState extends State<FollowList> {
  FollowStore followStore;
  EasyRefreshController _controller;

  @override
  void initState() {
    _controller = EasyRefreshController();
    followStore = FollowStore(
        RepositoryProvider.of<ApiClient>(context), widget.id, _controller);
    super.initState();
  }

  String restrict = 'public';

  Widget _buildBody() {
    if (accountStore.now != null) {
      if (int.parse(accountStore.now.userId) == widget.id) {
        return followStore.userList.isNotEmpty
            ? ListView.builder(
                itemCount: followStore.userList.length + 1,
                itemBuilder: (BuildContext context, int index) {
                  if (index == 0) {
                    return Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                          icon: Icon(Icons.list),
                          onPressed: () {
                            showModalBottomSheet(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(16),
                                  ),
                                ),
                                context: context,
                                builder: (context1) => SafeArea(
                                  child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          ListTile(
                                            title: Text(I18n.of(context).public),
                                            onTap: () {
                                              Navigator.of(context1).pop();
                                              followStore.fetch('public');
                                              restrict = 'public';
                                            },
                                          ),
                                          ListTile(
                                            title: Text(I18n.of(context).private),
                                            onTap: () {
                                              Navigator.of(context1).pop();
                                              followStore.fetch('private');
                                              restrict = 'private';
                                            },
                                          ),
                                        ],
                                      ),
                                ));
                          }),
                    );
                  }
                  UserPreviews user = followStore.userList[index - 1];
                  return PainterCard(
                    user: user,
                  );
                },
              )
            : Container();
      } else {
        return followStore.userList.isNotEmpty
            ? ListView.builder(
                itemCount: followStore.userList.length,
                itemBuilder: (BuildContext context, int index) {
                  UserPreviews user = followStore.userList[index];
                  return PainterCard(
                    user: user,
                  );
                },
              )
            : Container();
      }
    }
    return LoginInFirst();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        return EasyRefresh(
          header: MaterialHeader(),
          enableControlFinishLoad: true,
          enableControlFinishRefresh: true,
          controller: _controller,
          firstRefresh: true,
          onRefresh: () {
            return followStore.fetch(restrict);
          },
          onLoad: () {
            return followStore.fetchNext();
          },
          child: _buildBody(),
        );
      },
    );
  }
}
