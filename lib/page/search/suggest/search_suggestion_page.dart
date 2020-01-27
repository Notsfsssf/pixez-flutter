import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixez/generated/i18n.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/picture/picture_page.dart';
import 'package:pixez/page/search/bloc/suggestion_bloc.dart';
import 'package:pixez/page/search/bloc/suggestion_event.dart';
import 'package:pixez/page/search/bloc/suggestion_state.dart';
import 'package:pixez/page/search/result/search_result_page.dart';
import 'package:pixez/page/user/user_page.dart';

class SearchSuggestionPage extends StatefulWidget {
  @override
  _SearchSuggestionPageState createState() => _SearchSuggestionPageState();
}

class _SearchSuggestionPageState extends State<SearchSuggestionPage>
    with SingleTickerProviderStateMixin {
  TextEditingController _filter;
  TabController _tabController;
  @override
  void initState() {
    _filter = TextEditingController();
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _filter?.dispose();
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SuggestionBloc>(
      create: (BuildContext context) =>
          SuggestionBloc(RepositoryProvider.of<ApiClient>(context)),
      child: BlocBuilder<SuggestionBloc,SuggestionState>(
        builder: (context, snapshot) {
          return Scaffold(
            appBar: _buildAppBar(context),
            body: Container(child: Suggestions()),
          );
        }
      ),
    );
  }

  AppBar _buildAppBar(context) {
    return AppBar(
      title: TextField(
          controller: _filter,
          onChanged: (query) {
            if (query.startsWith('https://')) {
              Uri uri = Uri.parse(query);
              if (!uri.host.contains('pixiv')) {
                return;
              }
              final segment = uri.pathSegments;
              if (segment.length == 1 && query.contains("/member.php?id=")) {
                final id = uri.queryParameters['id'];
                Navigator.of(context, rootNavigator: true)
                    .push(MaterialPageRoute(builder: (BuildContext context) {
                  return UserPage(
                    id: int.parse(id),
                  );
                }));
                _filter.clear();
              }
              if (segment.length == 2) {
                if (segment[0] == 'artworks') {
                  Navigator.of(context, rootNavigator: true)
                      .push(MaterialPageRoute(builder: (BuildContext context) {
                    return PicturePage(null, int.parse(segment[1]));
                  }));
                  _filter.clear();
                }
                if (segment[0] == 'users') {
                  Navigator.of(context, rootNavigator: true)
                      .push(MaterialPageRoute(builder: (BuildContext context) {
                    return UserPage(
                      id: int.parse(segment[1]),
                    );
                  }));
                  _filter.clear();
                }
              }
            }
            var word = query.trim();
            if (word.isEmpty) return;

          BlocProvider.of<SuggestionBloc>(context).add(FetchSuggestionsEvent(word));
          },
          onSubmitted: (s) {
            var word = s.trim();
            if (word.isEmpty) return;

            switch (_tabController.index) {
              case 0:
                {
                  Navigator.of(context, rootNavigator: true)
                      .push(MaterialPageRoute(builder: (context) {
                    return SearchResultPage(
                      word: word,
                    );
                  }));
                }
                break;
              case 1:
                {
                  var id = int.tryParse(word);
                  if (id != null) {
                    Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute(
                            builder: (_) => PicturePage(null, id)));
                  } else {
                    _filter.clear();
                  }
                }
                break;
              case 2:
                {
                  var id = int.tryParse(word);
                  if (id != null) {
                    Navigator.of(context, rootNavigator: true)
                        .push(MaterialPageRoute(
                            builder: (_) => UserPage(
                                  id: id,
                                )));
                  } else {
                    _filter.clear();
                  }
                }
                break;
            }
          },
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.search),
            hintText: I18n.of(context).Search_word_or_paste_link,
          )),
      bottom: TabBar(
        controller: _tabController,
        tabs: <Widget>[
          Tab(
            child: Text(I18n.of(context).Illust),
          ),
          Tab(
            child: Text(I18n.of(context).Illust_id),
          ),
          Tab(
            child: Text(I18n.of(context).Painter + "ID"),
          ),
        ],
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.search),
          onPressed: () {
            _filter.clear();
          },
        )
      ],
    );
  }
}

class Suggestions extends StatefulWidget {
  const Suggestions({Key key}) : super(key: key);

  @override
  _SuggestionsState createState() => _SuggestionsState();
}

class _SuggestionsState extends State<Suggestions> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SuggestionBloc, SuggestionState>(
      builder: (context, state) {
        if (state is DataState) {
          final tags = state.autoWords.tags;
          return ListView.separated(
            itemBuilder: (context, index) {
              return ListTile(
                onTap: () {
                  FocusScope.of(context).requestFocus(FocusNode());
                  Navigator.of(context, rootNavigator: true)
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
            separatorBuilder: (BuildContext context, int index) {
              return Divider();
            },
          );
        }
        return Container();
      },
    );
  }
}
