import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/component/md2_tab_indicator.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/page/hello/ranking/rank_page.dart';
import 'package:pixez/page/hello/ranking/ranking_mode/rank_mode_page.dart';

class FluentRankPageState extends RankPageStateBase {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final rankListMean = I18n.of(context).mode_list.split(' ');
    return Observer(builder: (_) {
      if (rankStore.inChoice) {
        return _buildChoicePage(context, rankListMean);
      }
      if (rankStore.modeList.isNotEmpty) {
        var list = I18n.of(context).mode_list.split(' ');
        List<String> titles = [];
        for (var i = 0; i < rankStore.modeList.length; i++) {
          int index = modeList.indexOf(rankStore.modeList[i]);
          titles.add(list[index]);
        }
        return TabView(
          currentIndex: index,
          tabs: [
            for (var i in titles)
              Tab(
                text: Text(i),
              ),
          ],
          bodies: [
            for (var element in rankStore.modeList)
              RankModePage(
                date: dateTime,
                mode: element,
                index: rankStore.modeList.indexOf(element),
              ),
          ],
          header: CommandBar(primaryItems: [
            if (widget.toggleFullscreen != null)
              CommandBarButton(
                icon: Icon(FluentIcons.full_screen),
                onPressed: () {
                  toggleFullscreen();
                },
              ),
            if (index < rankStore.modeList.length)
              CommandBarButton(
                icon: Icon(FluentIcons.date_time),
                onPressed: () async {
                  await _showTimePicker(context);
                },
              ),
            // Visibility(
            //   visible: index < rankStore.modeList.length,
            //   child:
            // ),
            CommandBarButton(
              icon: Icon(FluentIcons.undo),
              onPressed: () {
                rankStore.reset();
              },
            )
          ], overflowBehavior: CommandBarOverflowBehavior.noWrap),
        );
      } else {
        return _buildChoicePage(context, rankListMean);
      }
    });
  }

  Widget _buildChoicePage(BuildContext context, List<String> rankListMean) {
    return ScaffoldPage(
      header: PageHeader(
        title: Text(I18n.of(context).choice_you_like),
        commandBar: CommandBar(primaryItems: [
          CommandBarButton(
            icon: Icon(FluentIcons.save),
            onPressed: () async {
              await rankStore.saveChange(boolList);
              rankStore.inChoice = false;
            },
          )
        ], overflowBehavior: CommandBarOverflowBehavior.noWrap),
      ),
      content: Padding(
        padding: EdgeInsets.all(8.0),
        child: Wrap(
          spacing: 4,
          children: [
            for (var e in rankListMean)
              ToggleButton(
                child: Text(e),
                checked: rankFilters.contains(e),
                onChanged: (v) {
                  boolList[rankListMean.indexOf(e)] = v;
                  if (v) {
                    setState(() {
                      rankFilters.add(e);
                    });
                  } else {
                    setState(() {
                      rankFilters.remove(e);
                    });
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  Future _showTimePicker(BuildContext context) async {
    // var nowdate = DateTime.now();
    final date = await showDialog<DateTime?>(
      context: context,
      builder: (context) {
        DateTime? result = null;
        return ContentDialog(
          title: Text("Select a time"),
          content: DatePicker(
            selected: nowDateTime,
            onChanged: (date) {
              result = date;
            },
            startYear: 2007,
          ),
          actions: [
            Button(
              child: Text("Cancel"),
              onPressed: () => Navigator.pop(context, null),
            ),
            FilledButton(
              child: Text("Ok"),
              onPressed: () => Navigator.pop(context, result),
            ),
          ],
        );
      },
    );
    // var date = await showDatePicker(
    //     context: context,
    //     initialDate: nowDateTime,
    //     locale: userSetting.locale,
    //     firstDate: DateTime(2007, 8),
    //     //pixiv于2007年9月10日由上谷隆宏等人首次推出第一个测试版...
    //     lastDate: nowdate);
    if (date != null && mounted) {
      nowDateTime = date;
      setState(() {
        this.dateTime = toRequestDate(date);
      });
    }
  }
}
