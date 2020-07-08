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
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/novel/component/novel_bookmark_button.dart';
import 'package:pixez/page/novel/recom/bloc.dart';
import 'package:pixez/page/novel/viewer/novel_viewer.dart';

class NovelRecomPage extends StatefulWidget {
  @override
  _NovelRecomPageState createState() => _NovelRecomPageState();
}

class _NovelRecomPageState extends State<NovelRecomPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<NovelRecomBloc>(
      child: BlocBuilder<NovelRecomBloc, NovelRecomState>(
          builder: (context, state) {
        return EasyRefresh(
          firstRefresh: true,
          onRefresh: () {
            BlocProvider.of<NovelRecomBloc>(context)
                .add(FetchNovelRecomEvent());
            return;
          },
          onLoad: () {},
          child: state is DataNovelRecomState
              ? ListView.builder(
                  itemCount: state.novels.length,
                  itemBuilder: (context, index) {
                    var novel = state.novels[index];
                    return ListTile(
                      title: Text(novel.title),
                      subtitle: Text(
                        novel.user.name,
                        maxLines: 1,
                      ),
                      onTap: () {
                        Navigator.of(context, rootNavigator: true).push(
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    NovelViewerPage(
                                      id: novel.id,
                                      novel: novel,
                                    )));
                      },
                      trailing: NovelBookmarkButton(novel: novel),
                    );
                  })
              : Container(),
        );
      }),
      create: (BuildContext context) => NovelRecomBloc(apiClient),
    );
  }
}
