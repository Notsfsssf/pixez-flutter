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
  TabController _tabController;
  @override
  void initState() {
    _tabController = TabController(vsync: this, length: modeList.length);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
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
          create: (context) => RankingBloc(),
        ),
      ],
      child: BlocBuilder<RankingBloc, RankingState>(builder: (context, state) {
        return Scaffold(
          appBar: buildAppBar(context),
          body: TabBarView(
              controller: _tabController,
              children: modeList.map((f) {
                return BlocBuilder<AccountBloc,AccountState>(
                  builder: (context, snapshot) {
                    if(snapshot is HasUserState)
                    return BlocProvider<RankingModeBloc>(
                      create: (BuildContext context) => RankingModeBloc(
                          RepositoryProvider.of<ApiClient>(context)),
                      child: BlocListener<RankingBloc, RankingState>(
                        child: RankingModePage(
                          mode: f,
                          date: null,
                        ),
                        listener: (BuildContext context, state) {
                          if (state is DateState) {
                            BlocProvider.of<RankingModeBloc>(context)
                                .add(FetchEvent(f, toRequestDate(state.dateTime)));
                          }
                        },
                      ),
                    );
                    return LoginInFirst();
                  }
                );
              }).toList()),
        );
      }),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      title: TabBar(
          isScrollable: true,
          indicatorSize: TabBarIndicatorSize.label,
          controller: _tabController,
          tabs: I18n.of(context).Mode_List.map((f) {
            return Tab(
              text: f,
            );
          }).toList()),
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
        )
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
