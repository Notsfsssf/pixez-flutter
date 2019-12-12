import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixez/generated/i18n.dart';
import 'package:pixez/models/trend_tags.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/search/bloc/bloc.dart';
import 'package:pixez/page/search/result/search_result_page.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String editString = "";

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TrendTagsBloc(ApiClient())..add(FetchEvent()),
      child: Scaffold(
        appBar: _buildAppBar(),
        body: Stack(
          children: <Widget>[
            _buildBlocBuilder(),
            Visibility(
              visible: this._searchIcon.icon != Icons.search,
              child: editString.isNotEmpty
                  ? Container(
                      decoration: BoxDecoration(color: Colors.white),
                      child: Suggestions(
                        query: editString,
                      ))
                  : Container(),
            )
          ],
        ),
      ),
    );
  }

  BlocBuilder<TrendTagsBloc, TrendTagsState> _buildBlocBuilder() {
    return BlocBuilder<TrendTagsBloc, TrendTagsState>(
        builder: (context, state) {
      if (state is TrendTagDataState) {
        return _buildListView(state.trendingTag.trend_tags);
      } else
        return Center(
          child: CircularProgressIndicator(),
        );
    });
  }

  Icon _searchIcon = Icon(Icons.search);
  final TextEditingController _filter = TextEditingController();
  Widget _appBarTitle = Text('Search');

  AppBar _buildAppBar() {
    return AppBar(
      title: _appBarTitle,
      actions: <Widget>[
        IconButton(
          icon: _searchIcon,
          onPressed: () {
            setState(() {
              if (this._searchIcon.icon == Icons.search) {
                this._searchIcon = Icon(Icons.close);
                this._appBarTitle = TextField(
                  controller: _filter,
                  onChanged: (query) {
                    setState(() {
                      editString = query;
                    });
                  },
                  style: TextStyle(
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search, color: Colors.white),
                      hintText: "Search...",
                      hintStyle: TextStyle(color: Colors.white)),
                );
              } else {
                this._searchIcon = Icon(Icons.search);
                this._appBarTitle = Text(I18n.of(context).Search);
                _filter.clear();
                editString = '';
              }
            });
          },
        )
      ],
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
      IconButton(
        icon: Icon(Icons.calendar_view_day),
        onPressed: () {
          showModalBottomSheet(
              context: context,
              builder: (context) {
                return Container();
              });
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
    return SearchResultPage(
      word: query,
    );
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
              return ListTile(
                onTap: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return SearchResultPage(
                      word: tags[index].name,
                    );
                  }));
                },
                title: Text(tags[index].name),
                subtitle: Text(tags[index].translated_name ?? ""),
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
