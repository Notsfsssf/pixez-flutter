import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixez/generated/i18n.dart';
import 'package:pixez/models/trend_tags.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/search/bloc/bloc.dart';
import 'package:pixez/page/search/result/search_result_page.dart';
import 'package:pixez/page/search/suggest/search_suggestion_page.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with SingleTickerProviderStateMixin {
  String editString = "";

  @override
  void initState() {
    _filter = TextEditingController();
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
    BlocProvider.of<TagHistoryBloc>(context).add(FetchAllTagHistoryEvent());
  }

  @override
  void dispose() {
    _filter?.dispose();
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<TrendTagsBloc>(
          create: (context) =>
          TrendTagsBloc(RepositoryProvider.of<ApiClient>(context))
            ..add(FetchEvent()),
        )
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(I18n.of(context).Search),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                Navigator.of(context,rootNavigator: true).push(
                    MaterialPageRoute(
                        builder: (context) => SearchSuggestionPage()));
              },
            )
          ],
        ),
        body: _buildBlocBuilder(),
      ),
    );
  }

  Widget _buildBlocBuilder() {
    return BlocBuilder<TrendTagsBloc, TrendTagsState>(
        builder: (context, state) {
      return _buildListView(state);
    });
  }

  TextEditingController _filter;
  TabController _tabController;

  ListView _buildListView(TrendTagsState state) {
    return ListView.builder(
      itemCount: 4,
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(I18n
                .of(context)
                .History),
          );
        }
        if (index == 1) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(I18n
                .of(context)
                .Recommand_Tag),
          );
        }
        if (index == 2) {
          return BlocBuilder<TagHistoryBloc, TagHistoryState>(
            builder: (BuildContext context, TagHistoryState state) {
              if (state is TagHistoryDataState &&
                  state.tagsPersistList.isNotEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Wrap(
                    children: state.tagsPersistList
                        .map((f) =>
                        ActionChip(
                          label: Text(f.name),
                          onPressed: () {
                            Navigator.of(context, rootNavigator: true)
                                .push(MaterialPageRoute(builder: (context) =>
                                SearchResultPage(
                                  word: f.name,
                                )));
                          },
                        ))
                        .toList()
                      ..add(ActionChip(
                          label: Text(I18n.of(context).Clear),
                          onPressed: () {
                            BlocProvider.of<TagHistoryBloc>(context)
                                .add(DeleteAllTagHistoryEvent());
                          })),
                    runSpacing: 0.0,
                    spacing: 3.0,
                  ),
                );
              }
              return Container();
            },
          );
        } else {
          if (state is TrendTagDataState)
            return _buildGrid(context, state.trendingTag.trend_tags);
          else
            return Container();
        }
      },
    );
  }

  Widget _buildGrid(BuildContext context, List<Trend_tags> tags) =>
      GridView.count(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        crossAxisCount: 3,
        children: List.generate(tags.length, (index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context, rootNavigator: true)
                    .push(MaterialPageRoute(builder: (_) {
                  return SearchResultPage(
                    word: tags[index].tag,
                  );
                }));
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3.0),
                child: Stack(
                  children: <Widget>[
                    CachedNetworkImage(
                      imageUrl: tags[index].illust.imageUrls.squareMedium,
                      httpHeaders: {
                        "referer": "https://app-api.pixiv.net/",
                        "User-Agent": "PixivIOSApp/5.8.0"
                      },
                      fit: BoxFit.fitWidth,
                    ),
                    Align(
                      child: Text(tags[index].tag),
                      alignment: Alignment.bottomCenter,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      );
}
