import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/lighting/lighting_store.dart';
import 'package:pixez/main.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/novel/component/novel_lighting_list.dart';

class NovelResultList extends StatefulWidget {
  final String word;

  const NovelResultList({Key? key, required this.word}) : super(key: key);

  @override
  _NovelResultListState createState() => _NovelResultListState();
}

class _NovelResultListState extends State<NovelResultList> {
  @override
  void initState() {
    futureGet = ApiForceSource(futureGet:(bool e)=> apiClient.getSearchNovel(widget.word));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              InkWell(
                onTap: () {

                },
                child: Container(
                  width: MediaQuery.of(context).size.width * 2 / 3,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 16.0),
                      child: Text(
                        widget.word,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  children: [
                    IconButton(
                        icon: Icon(Icons.date_range),
                        onPressed: () {
                          _buildShowDateRange(context);
                        }),
                    _buildStar(),
                    IconButton(
                        icon: Icon(Icons.filter_alt_outlined),
                        onPressed: () {
                          _buildShowBottomSheet(context);
                          // _showMaterialBottom();
                        }),
                  ],
                ),
              )
            ],
          ),

          Expanded(
            child: NovelLightingList(
                futureGet: () => futureGet.fetch(false)),
          ),
        ],
      ),
    );
  }

  List<int> starNum = [
    0,
    100,
    250,
    500,
    1000,
    5000,
    10000,
    20000,
    30000,
    50000,
  ];

  final sort = ["date_desc", "date_asc", "popular_desc"];
  static List<String> search_target = [
    "partial_match_for_tags",
    "exact_match_for_tags",
    "text",
    "keyword"
  ];
  String searchTarget = search_target[0];
  String selectSort = "date_desc";
  int selectStarNum = 0;

  DateTimeRange? _dateTimeRange;

  Future _buildShowDateRange(BuildContext context) async {
    DateTimeRange? dateTimeRange = await showDateRangePicker(
        context: context,
        initialDateRange: _dateTimeRange,
        firstDate: DateTime.fromMillisecondsSinceEpoch(
            DateTime.now().millisecondsSinceEpoch -
                (24 * 60 * 60 * 365 * 1000 * 8)),
        lastDate: DateTime.now());
    if (dateTimeRange != null) {
      _dateTimeRange = dateTimeRange;
      setState(() {
        _changeQueryParams();
      });
    }
  }

  late ApiForceSource futureGet;
  var _starValue = 0;

  _changeQueryParams() {
    if (_starValue == 0)
      futureGet = ApiForceSource(
          futureGet: (bool e) => apiClient.getSearchNovel(widget.word,
              search_target: searchTarget,
              sort: selectSort,
              start_date: _dateTimeRange?.start,
              end_date: _dateTimeRange?.end));
    else
      futureGet = ApiForceSource(
          futureGet: (bool e) => apiClient.getSearchNovel(
              '${widget.word} ${_starValue}users入り',
              search_target: searchTarget,
              sort: selectSort,
              start_date: _dateTimeRange?.start,
              end_date: _dateTimeRange?.end));
  }


  void _buildShowBottomSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(8.0))),
        builder: (context) {
          return StatefulBuilder(builder: (_, setS) {
            return SafeArea(
              child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          TextButton(
                              onPressed: () {},
                              child: Text(I18n.of(context).filter,
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary))),
                          TextButton(
                              onPressed: () {
                                setState(() {
                                  _changeQueryParams();
                                });
                                Navigator.of(context).pop();
                              },
                              child: Text(I18n.of(context).apply,
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary))),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: CupertinoSlidingSegmentedControl(
                            groupValue: search_target.indexOf(searchTarget),
                            children: <int, Widget>{
                              0: Text(I18n.of(context).partial_match_for_tag),
                              1: Text(I18n.of(context).exact_match_for_tag),
                              2: Text(I18n.of(context).text),
                              3: Text(I18n.of(context).key_word),
                            },
                            onValueChanged: (int? index) {
                              setS(() {
                                searchTarget = search_target[index!];
                              });
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: CupertinoSlidingSegmentedControl(
                            groupValue: sort.indexOf(selectSort),
                            children: <int, Widget>{
                              0: Text(I18n.of(context).date_desc),
                              1: Text(I18n.of(context).date_asc),
                              2: Text(I18n.of(context).popular_desc),
                            },
                            onValueChanged: (int? index) {
                              if (accountStore.now != null && index == 2) {
                                if (accountStore.now!.isPremium == 0) {
                                  BotToast.showText(text: 'not premium');
                                  Navigator.of(context).pop();
                                  return;
                                }
                              }
                              setS(() {
                                selectSort = sort[index!];
                              });
                            },
                          ),
                        ),
                      ),
                      Container(
                        height: 16,
                      )
                    ],
                  )),
            );
          });
        });
  }

  Widget _buildStar() {
    return PopupMenuButton(
      initialValue: _starValue,
      child: Icon(
        Icons.sort,
      ),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16.0))),
      itemBuilder: (context) {
        return starNum.map((int value) {
          if (value > 0) {
            return PopupMenuItem(
              value: value,
              child: Text("${value} users入り"),
              onTap: () {
                setState(() {
                  _starValue = value;
                  _changeQueryParams();
                });
              },
            );
          } else {
            return PopupMenuItem(
              value: value,
              child: Text("Default"),
              onTap: () {
                setState(() {
                  _starValue = value;
                  _changeQueryParams();
                });
              },
            );
          }
        }).toList();
      },
    );
  }
}
