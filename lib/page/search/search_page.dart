import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixez/generated/i18n.dart';
import 'package:pixez/models/tags.dart';
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
  Widget _appBarTitle = Text("Search");

  @override
  void initState() {
    super.initState();
    BlocProvider.of<TagHistoryBloc>(context).add(FetchAllTagHistoryEvent());
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<TrendTagsBloc>(
          create: (context) => TrendTagsBloc(ApiClient())..add(FetchEvent()),
        )
      ],
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

  Widget _buildBlocBuilder() {
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
      itemCount: 3,
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
         return Padding(
           padding: const EdgeInsets.all(8.0),
           child: Text(I18n.of(context).History),
         );
        } if(index==1){
          return BlocBuilder<TagHistoryBloc, TagHistoryState>(
            builder: (BuildContext context, TagHistoryState state) {
              if(state is TagHistoryDataState&&state.tagsPersistList.isNotEmpty){
                return Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Wrap(children: state.tagsPersistList.map((f)=>ActionChip(label: Text(f.name), onPressed: () {},)).toList()..add(ActionChip(label: Text(I18n.of(context).Clear), onPressed: (){
                    BlocProvider.of<TagHistoryBloc>(context)
                        .add(DeleteAllTagHistoryEvent());
                  })),runSpacing: 0.0,
                  spacing: 3.0,),
                );
              }
              return Container();
            },
          );
        }
        else {
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
          return ListView.separated(
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
            itemCount: tags.length, separatorBuilder: (BuildContext context, int index) {return Divider();},
          );
        }
        return Container();
      },
    );
  }
}