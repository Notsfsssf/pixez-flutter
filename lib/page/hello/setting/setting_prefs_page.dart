import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';

class SettingPrefsPage extends StatefulWidget {
  const SettingPrefsPage({Key? key}) : super(key: key);

  @override
  State<SettingPrefsPage> createState() => _SettingPrefsPageState();
}

class _SettingPrefsPageState extends State<SettingPrefsPage> {
  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      return Scaffold(
        appBar: AppBar(title: Text(I18n.of(context).setting)),
        body: CustomScrollView(slivers: [
          SliverToBoxAdapter(
            child: Container(
              height: 30,
            ),
          ),
          SliverToBoxAdapter(
              child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Column(children: [
                _buildRow(I18n.of(context).select_language,
                    subtitle: userSetting.languageList[userSetting.languageNum],
                    onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => SettingLanguagePage()));
                }),
              ]),
            ),
          )),
          SliverToBoxAdapter(
            child: Container(
              height: 10,
            ),
          ),
          SliverToBoxAdapter(
              child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Column(children: [
                _buildRow(I18n.of(context).illustration_detail_page_quality,
                    subtitle: userSetting.languageList[userSetting.languageNum],
                    onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => SettingLanguagePage()));
                }),
                _buildRow(I18n.of(context).manga_detail_page_quality,
                    subtitle: userSetting.languageList[userSetting.languageNum],
                    onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => SettingLanguagePage()));
                }),
                _buildRow(I18n.of(context).large_preview_zoom_quality,
                    subtitle: userSetting.languageList[userSetting.languageNum],
                    onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => SettingLanguagePage()));
                }),
              ]),
            ),
          ))
        ]),
      );
    });
  }

  Widget _buildRow(String title,
      {String? subtitle, GestureTapCallback? onTap}) {
    return InkWell(
      onTap: () {
        onTap?.call();
      },
      child: Padding(
        padding: const EdgeInsets.all(14.5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title),
            Container(
                child: Row(children: [
              Text(
                subtitle ?? "",
                style: TextStyle(
                    color: Theme.of(context).textTheme.caption!.color),
              ),
              Icon(
                Icons.keyboard_arrow_right,
                color: Theme.of(context).textTheme.caption!.color,
              )
            ]))
          ],
        ),
      ),
    );
  }
}

class SettingLanguagePage extends StatefulWidget {
  const SettingLanguagePage({Key? key}) : super(key: key);

  @override
  State<SettingLanguagePage> createState() => _SettingLanguagePageState();
}

class _SettingLanguagePageState extends State<SettingLanguagePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(I18n.of(context).select_language)),
      body: CustomScrollView(slivers: [
        SliverToBoxAdapter(
          child: Container(
            height: 30,
          ),
        ),
        SliverToBoxAdapter(
            child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Card(
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(children: [
              for (var i in userSetting.languageList)
                SettingSelectRow(
                    title: i,
                    select: userSetting.languageNum ==
                        userSetting.languageList.indexOf(i),
                    onTap: () {
                      int index = userSetting.languageList.indexOf(i);
                      if (index == -1) return;
                      userSetting.setLanguageNum(index);
                      Navigator.of(context).pop();
                    }),
            ]),
          ),
        ))
      ]),
    );
  }
}

class SettingSelectPage extends StatefulWidget {
  final String title;
  const SettingSelectPage({Key? key, required this.title}) : super(key: key);

  @override
  State<SettingSelectPage> createState() => _SettingSelectPageState();
}

class _SettingSelectPageState extends State<SettingSelectPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
    );
  }
}

class SettingSelectRow extends StatefulWidget {
  final String title;
  bool select;
  GestureTapCallback? onTap;
  SettingSelectRow(
      {Key? key, required this.title, required this.select, this.onTap})
      : super(key: key);

  @override
  State<SettingSelectRow> createState() => _SettingSelectRowState();
}

class _SettingSelectRowState extends State<SettingSelectRow> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        widget.onTap?.call();
      },
      child: Padding(
        padding: const EdgeInsets.all(14.5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(widget.title),
            Container(
                child: Row(children: [
              if (widget.select)
                Icon(
                  Icons.check,
                  color: Theme.of(context).textTheme.caption!.color,
                )
            ]))
          ],
        ),
      ),
    );
  }
}

class SettingRow extends StatefulWidget {
  final String title;
  String? subTitle;
  GestureTapCallback? onTap;
  SettingRow({Key? key, required this.title, this.subTitle, this.onTap})
      : super(key: key);

  @override
  State<SettingRow> createState() => _SettingRowState();
}

class _SettingRowState extends State<SettingRow> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        widget.onTap?.call();
      },
      child: Padding(
        padding: const EdgeInsets.all(14.5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(widget.title),
            Container(
                child: Row(children: [
              Text(
                widget.subTitle ?? "",
                style: TextStyle(
                    color: Theme.of(context).textTheme.caption!.color),
              ),
              Icon(
                Icons.keyboard_arrow_right,
                color: Theme.of(context).textTheme.caption!.color,
              )
            ]))
          ],
        ),
      ),
    );
  }
}
