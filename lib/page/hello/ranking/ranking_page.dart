import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:pixez/bloc/account_bloc.dart';
import 'package:pixez/bloc/account_state.dart';
import 'package:pixez/generated/i18n.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/hello/ranking/bloc.dart';
import 'package:pixez/page/hello/ranking/ranking_mode/bloc.dart';
import 'package:pixez/page/hello/ranking/ranking_mode/ranking_mode_page.dart';
import 'package:pixez/page/preview/preview_page.dart';

class RankingPage extends StatefulWidget {
  @override
  _RankingPageState createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  final modeList = [
    "day",
    "day_male",
    "day_female",
    "week_original",
    "week_rookie",
    "week",
    "month",
    "day_r18",
    "week_r18"
  ];
  var boolList = Map<String, bool>();

  @override
  void initState() {
    modeList.forEach((f) {
      boolList[f] = false;
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  String toRequestDate(DateTime dateTime) {
    if (dateTime == null) {
      return null;
    }
    debugPrint("${dateTime.year}-${dateTime.month}-${dateTime.day}");
    return "${dateTime.year}-${dateTime.month}-${dateTime.day}";
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: <BlocProvider>[
        BlocProvider<RankingBloc>(
          create: (context) => RankingBloc()..add(DateChangeEvent(null)),
        ),
      ],
      child: BlocBuilder<RankingBloc, RankingState>(builder: (context, state) {
        if (state is DateState) {
          return DefaultTabController(
            child: Scaffold(
              appBar: buildAppBar(context, state.modeList),
              body: TabBarView(
                  children: state.modeList.map((f) {
                    return BlocBuilder<AccountBloc, AccountState>(
                        builder: (context, snapshot) {
                          if (snapshot is HasUserState)
                            return BlocProvider<RankingModeBloc>(
                              create: (BuildContext context) =>
                                  RankingModeBloc(
                                      RepositoryProvider.of<ApiClient>(
                                          context)),
                              child: BlocListener<RankingBloc, RankingState>(
                                child: RankingModePage(
                                  mode: f,
                                  date: null,
                                ),
                                listener: (BuildContext context, state) {
                                  if (state is DateState) {
                                    BlocProvider.of<RankingModeBloc>(context)
                                        .add(
                                        FetchEvent(
                                            f, toRequestDate(state.dateTime)));
                                  }
                                },
                              ),
                            );
                          return LoginInFirst();
                        });
                  }).toList()),
            ), length: state.modeList.length,
          );
        }
        if (state is ModifyModeListState) {
          return Scaffold(
            appBar: AppBar(
              title: Text(I18n
                  .of(context)
                  .Choice_you_like),
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.save),
                  onPressed: () {
                    BlocProvider.of<RankingBloc>(context)
                        .add(SaveChangeEvent(boolList));
                  },
                )
              ],
            ),
            body: ListView.builder(
              itemCount: I18n
                  .of(context)
                  .Mode_List
                  .length,
              itemBuilder: (BuildContext context, int index) {
                var value = modeList[index];
                return CheckboxListTile(
                  title: Text(I18n
                      .of(context)
                      .Mode_List[index]),
                  onChanged: (bool value) {
                    setState(() {
                      boolList[modeList[index]] = value;
                    });
                  },
                  value: boolList[modeList[index]],
                );
              },
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(), body: Center(child: CircularProgressIndicator(),),);
      }),
    );
  }

  AppBar buildAppBar(BuildContext context,
      List<String> modeList1) {
    List<Widget> tabs = [];
    modeList1.forEach((f) {
      tabs.add(Tab(
        text: I18n
            .of(context)
            .Mode_List[modeList.indexOf(f)],
      ));
    });
    return AppBar(
      title: TabBar(
        isScrollable: true,
        indicatorSize: TabBarIndicatorSize.label,
        tabs: tabs,
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.date_range),
          onPressed: () {
            var theme = Theme.of(context);
            DatePicker.showDatePicker(context,
                maxDateTime: DateTime.now(),
                initialDateTime: DateTime.now(),
                pickerTheme: DateTimePickerTheme(
                    itemTextStyle: theme.textTheme.subtitle,
                    backgroundColor: theme.dialogBackgroundColor,
                    confirmTextStyle: theme.textTheme.subhead,
                    cancelTextStyle: theme.textTheme.subhead),
                onConfirm: (DateTime dateTime, List<int> list) {
                  BlocProvider.of<RankingBloc>(context)
                      .add(DateChangeEvent(dateTime));
                });
          },
        ),
        IconButton(
          icon: Icon(Icons.undo),
          onPressed: () {
            BlocProvider.of<RankingBloc>(context).add(ResetEvent());
          },
        )
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
