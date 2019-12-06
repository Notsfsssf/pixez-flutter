import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixez/models/trend_tags.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/search/bloc/bloc.dart';
import 'package:pixez/page/search/result/search_result_page.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      builder: (context) => TrendTagsBloc(ApiClient())..add(FetchEvent()),
      child: Scaffold(
        appBar: AppBar(
          title: Text("Search"),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: CustomSearchDelegate(),
                );
              },
            )
          ],
        ),
        body: BlocBuilder<TrendTagsBloc, TrendTagsState>(
            builder: (context, state) {
          if (state is TrendTagDataState) {
            return _buildListView(state.trendingTag.trend_tags);
          } else
            return Center(
              child: CircularProgressIndicator(),
            );
        }),
      ),
    );
  }

  ListView _buildListView(List<Trend_tags> tags) {
    return ListView.builder(
      itemCount: 2,
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          return Container();
        } else {
          return _buildGrid(context, tags);
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
                Navigator.push(context, MaterialPageRoute(builder: (_) {
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

class CustomSearchDelegate extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return SearchResultPage(word: query,);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty)
      return Column(
        children: <Widget>[Text("d")],
      );
    else
      return Suggestions(
        query: query,
      );
  }
}

class Suggestions extends StatefulWidget {
  final String query;

  const Suggestions({Key key, this.query}) : super(key: key);

  @override
  _SuggestionsState createState() => _SuggestionsState();
}

class _SuggestionsState extends State<Suggestions> {
  final SuggestionBloc _bloc = SuggestionBloc(ApiClient());

  @override
  Widget build(BuildContext context) {
    _bloc.add(FetchSuggestionsEvent(widget.query));
    return BlocBuilder(
      bloc: _bloc,
      builder: (context, state) {
        if (state is DataState) {
          final tags = state.autoWords.tags;
          return ListView.builder(
            itemBuilder: (context, index) {
              return Container(
                child: ListTile(
                  title: Text(tags[index].name),
                  subtitle: Text(tags[index].translated_name ?? ""),
                ),
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(width: 1, color: Color(0xffe5e5e5)))
                ),
              );
            },
            itemCount: tags.length,

          );
        }
        return Container();
      },
    );
  }
}
