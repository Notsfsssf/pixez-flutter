import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/search/bloc/bloc.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
      body: BlocProvider(
        builder: (context) => TrendTagsBloc(ApiClient())..add(FetchEvent()),
        child: BlocBuilder<TrendTagsBloc, TrendTagsState>(
          builder: (context, state) {
            if (state is TrendTagDataState) {
              final tags = state.trendingTag.trend_tags;
              return GridView.count(
                crossAxisCount: 3,
                children: List.generate(tags.length, (index) {
                  return CachedNetworkImage(
                    imageUrl: tags[index].illust.imageUrls.squareMedium,
                    httpHeaders: {
                      "referer": "https://app-api.pixiv.net/",
                      "User-Agent": "PixivIOSApp/5.8.0"
                    },
                    fit: BoxFit.fitWidth,
                  );
                }),
              );
            }
            return Container();
          },
        ),
      ),
    );
  }
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
    return Column(
      children: <Widget>[Text("xxx")],
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Column(
      children: <Widget>[Text("d")],
    );
  }
}
