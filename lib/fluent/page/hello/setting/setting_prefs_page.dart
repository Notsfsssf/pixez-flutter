import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/er/leader.dart';
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
      return ScaffoldPage(
        header: PageHeader(title: Text(I18n.of(context).setting)),
        content: CustomScrollView(slivers: [
          SliverToBoxAdapter(
            child: Container(
              height: 30,
            ),
          ),
          SliverToBoxAdapter(
              child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              child: Column(children: [
                _buildRow(I18n.of(context).select_language,
                    subtitle: userSetting.languageList[userSetting.languageNum],
                    onTap: () {
                  Leader.push(
                    context,
                    SettingLanguagePage(),
                    icon: Icon(FluentIcons.locale_language),
                    title: Text(I18n.of(context).select_language),
                  );
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
              child: Column(children: [
                _buildRow(I18n.of(context).illustration_detail_page_quality,
                    subtitle: userSetting.languageList[userSetting.languageNum],
                    onTap: () {
                  Leader.push(
                    context,
                    SettingLanguagePage(),
                    icon: Icon(FluentIcons.locale_language),
                    title: Text(I18n.of(context).select_language),
                  );
                }),
                _buildRow(I18n.of(context).manga_detail_page_quality,
                    subtitle: userSetting.languageList[userSetting.languageNum],
                    onTap: () {
                  Leader.push(
                    context,
                    SettingLanguagePage(),
                    icon: Icon(FluentIcons.locale_language),
                    title: Text(I18n.of(context).select_language),
                  );
                }),
                _buildRow(I18n.of(context).large_preview_zoom_quality,
                    subtitle: userSetting.languageList[userSetting.languageNum],
                    onTap: () {
                  Leader.push(
                    context,
                    SettingLanguagePage(),
                    icon: Icon(FluentIcons.locale_language),
                    title: Text(I18n.of(context).select_language),
                  );
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
    return IconButton(
      onPressed: () {
        onTap?.call();
      },
      icon: Padding(
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
                    color: FluentTheme.of(context).typography.caption!.color),
              ),
              Icon(
                FluentIcons.go,
                color: FluentTheme.of(context).typography.caption!.color,
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
    return ScaffoldPage(
      header: PageHeader(title: Text(I18n.of(context).select_language)),
      content: CustomScrollView(slivers: [
        SliverToBoxAdapter(
          child: Container(
            height: 30,
          ),
        ),
        SliverToBoxAdapter(
            child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Card(
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
    return ScaffoldPage(
      header: PageHeader(
        title: Text(widget.title),
      ),
    );
  }
}

class SettingSelectRow extends StatefulWidget {
  final String title;
  final bool select;
  final GestureTapCallback? onTap;
  const SettingSelectRow(
      {Key? key, required this.title, required this.select, this.onTap})
      : super(key: key);

  @override
  State<SettingSelectRow> createState() => _SettingSelectRowState();
}

class _SettingSelectRowState extends State<SettingSelectRow> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        widget.onTap?.call();
      },
      icon: Padding(
        padding: const EdgeInsets.all(14.5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(widget.title),
            Container(
                child: Row(children: [
              if (widget.select)
                Icon(
                  FluentIcons.check_mark,
                  color: FluentTheme.of(context).typography.caption!.color,
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
  final String? subTitle;
  final GestureTapCallback? onTap;
  const SettingRow({Key? key, required this.title, this.subTitle, this.onTap})
      : super(key: key);

  @override
  State<SettingRow> createState() => _SettingRowState();
}

class _SettingRowState extends State<SettingRow> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        widget.onTap?.call();
      },
      icon: Padding(
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
                    color: FluentTheme.of(context).typography.caption!.color),
              ),
              Icon(
                FluentIcons.go,
                color: FluentTheme.of(context).typography.caption!.color,
              )
            ]))
          ],
        ),
      ),
    );
  }
}
