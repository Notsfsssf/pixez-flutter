import 'package:bot_toast/bot_toast.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:pixez/component/fluent/pixez_button.dart';
import 'package:pixez/component/fluent/pixiv_image.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/page/fluent/picture/illust_lighting_page.dart';
import 'package:pixez/page/fluent/search/result_page.dart';
import 'package:pixez/page/fluent/soup/soup_page.dart';
import 'package:pixez/page/fluent/user/users_page.dart';
import 'package:pixez/page/saucenao/sauce_store.dart';
import 'package:pixez/page/search/suggest/suggestion_store.dart';
import 'package:pixez/page/search/trend_tags_store.dart';

class SearchBox extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SearchBoxState();
}

class _SearchBoxState extends State<StatefulWidget> {
  final List<AutoSuggestBoxItem<String>> _suggestList = [];
  final TextEditingController _filter = TextEditingController();
  final SuggestionStore _suggestionStore = SuggestionStore();
  final SauceStore _sauceStore = SauceStore();
  final TrendTagsStore _trendTagsStore = TrendTagsStore();
  final List<String> tagGroup = [];

  @override
  void initState() {
    _sauceStore.observableStream.listen((event) {
      if (event != null && _sauceStore.results.isNotEmpty) {
        Leader.push(
          context,
          PageView(
            children: _sauceStore.results
                .map((element) => IllustLightingPage(id: element))
                .toList(),
          ),
          icon: Icon(FluentIcons.search),
          title: Text(I18n.of(context).search),
        );
      } else {
        BotToast.showText(text: "0 result");
      }
    });
    var query = '';
    var tags = query
        .split(" ")
        .map((e) => e.trim())
        .takeWhile((value) => value.isNotEmpty);
    if (tags.length > 1) tagGroup.addAll(tags);
    super.initState();
    tagHistoryStore.fetch().then(
        (value) => _onAutoSuggestBoxChanged('', TextChangedReason.cleared));
    _trendTagsStore.fetch();
  }

  @override
  Widget build(BuildContext context) {
    return AutoSuggestBox<String>(
      items: _suggestList,
      controller: _filter,
      onChanged: _onAutoSuggestBoxChanged,
      placeholder: I18n.of(context).search,
      leadingIcon: IconButton(
        icon: const Icon(FluentIcons.image_search),
        onPressed: _sauceStore.findImage,
      ),
      trailingIcon: IconButton(
        icon: const Icon(FluentIcons.search),
        onPressed: () => Leader.push(
          context,
          ResultPage(word: _filter.text),
          icon: const Icon(FluentIcons.search),
          title: Text('搜索 ${_filter.text}'),
        ),
      ),
    );
  }

  void _onAutoSuggestBoxChanged(String text, TextChangedReason reason) {
    if (reason == TextChangedReason.suggestionChosen) {
      _filter.text = '';
      setState(() {});
      return;
    }
    _suggestList.clear();
    if (text.isEmpty) {
      if (tagHistoryStore.tags.isNotEmpty)
        _suggestList.add(_buildItem(
          title: I18n.of(context).clear_search_tag_history,
          onSelected: () => showDialog(
            context: context,
            builder: (context) {
              return ContentDialog(
                title: Text("Clean history?"),
                actions: [
                  Button(
                    onPressed: Navigator.of(context).pop,
                    child: Text(I18n.of(context).cancel),
                  ),
                  FilledButton(
                    onPressed: () {
                      tagHistoryStore.deleteAll();
                      Navigator.of(context).pop();
                    },
                    child: Text(I18n.of(context).ok),
                  )
                ],
              );
            },
          ),
        ));
      _suggestList.addAll(
        tagHistoryStore.tags.map(
          (e) => _buildItem(
            title: e.name,
            subtitle: e.translatedName,
            onSelected: () {
              if (tagGroup.length > 1) {
                tagGroup.last = e.name;
                final text = tagGroup.join(" ");
                _filter.text = text;
                _filter.selection = TextSelection.fromPosition(
                  TextPosition(offset: text.length),
                );
                setState(() {});
              } else {
                FocusScope.of(context).unfocus();
                Leader.push(
                  context,
                  ResultPage(
                    word: e.name,
                    translatedName: e.translatedName,
                  ),
                  icon: Icon(FluentIcons.search),
                  title: Text('${I18n.of(context).search}: ${e.name}'),
                );
              }
            },
          ),
        ),
      );

      setState(() {});
    } else if (text == '#') {
      _suggestList.addAll(
        _trendTagsStore.trendTags.map(
          (e) => _buildItem(
            title: "#${e.tag}",
            subtitle: e.translatedName,
            leading: PixEzButton(
              noPadding: true,
              child: PixivImage(
                e.illust.imageUrls.squareMedium,
                fit: BoxFit.cover,
                height: 26,
              ),
              onPressed: () {
                Leader.push(
                  context,
                  IllustLightingPage(id: e.illust.id),
                  icon: Icon(FluentIcons.picture),
                  title: Text(
                    I18n.of(context).illust_id + ': ${e.illust.id}',
                  ),
                );
              },
            ),
            onSelected: () {
              if (tagGroup.length > 1) {
                tagGroup.last = e.tag;
                final text = tagGroup.join(" ");
                _filter.text = text;
                _filter.selection = TextSelection.fromPosition(
                  TextPosition(offset: text.length),
                );
                setState(() {});
              } else {
                FocusScope.of(context).unfocus();
                Leader.push(
                  context,
                  ResultPage(
                    word: e.tag,
                  ),
                  icon: Icon(FluentIcons.search),
                  title: Text('${I18n.of(context).search}: ${e.tag}'),
                );
              }
            },
          ),
        ),
      );

      setState(() {});
    } else {
      final id = int.tryParse(text);
      if (id != null) {
        _suggestList.addAll([
          _getItemByIllustId(id),
          _getItemByPainterId(id),
          _getItemByPixivisionId(id),
        ]);
      }

      if (_suggestionStore.autoWords?.tags.isNotEmpty != true) return;

      _suggestList.addAll(
        _suggestionStore.autoWords!.tags.map(
          (e) => _buildItem(
            title: e.name,
            subtitle: e.translated_name,
            onSelected: () {
              if (tagGroup.length > 1) {
                tagGroup.last = e.name;
                final text = tagGroup.join(" ");
                _filter.text = text;
                _filter.selection = TextSelection.fromPosition(
                  TextPosition(offset: text.length),
                );
                setState(() {});
              } else {
                FocusScope.of(context).unfocus();
                Leader.push(
                  context,
                  ResultPage(
                    word: e.name,
                    translatedName: e.translated_name ?? '',
                  ),
                  icon: Icon(FluentIcons.search),
                  title: Text('${I18n.of(context).search}: ${e.name}'),
                );
              }
            },
          ),
        ),
      );

      setState(() {});
    }
  }

  AutoSuggestBoxItem<String> _buildItem({
    required String title,
    String? subtitle = null,
    Widget? leading = null,
    void Function()? onSelected,
  }) {
    return AutoSuggestBoxItem<String>(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null)
            Padding(
              padding: EdgeInsets.only(right: 4.0),
              child: leading,
            ),
          Text(
            title,
            style: FluentTheme.of(context).typography.body?.copyWith(
                  color: FluentTheme.of(context).accentColor,
                ),
          ),
          if (subtitle != null && subtitle.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(left: 4.0),
              child: Text(subtitle),
            ),
        ],
      ),
      label: title,
      value: title,
      onSelected: onSelected,
    );
  }

  AutoSuggestBoxItem<String> _getItemByIllustId(int id) {
    final text = '${I18n.of(context).illust_id}: ${id}';
    return _buildItem(
      title: I18n.of(context).illust_id,
      subtitle: id.toString(),
      onSelected: () => Leader.push(
        context,
        IllustLightingPage(id: id),
        icon: const Icon(FluentIcons.image_pixel),
        title: Text(text),
      ),
    );
  }

  AutoSuggestBoxItem<String> _getItemByPainterId(int id) {
    final text = '${I18n.of(context).painter_id}: ${id}';
    return _buildItem(
      title: I18n.of(context).painter_id,
      subtitle: id.toString(),
      onSelected: () => Leader.push(
        context,
        UsersPage(id: id),
        icon: const Icon(FluentIcons.image_pixel),
        title: Text(text),
      ),
    );
  }

  AutoSuggestBoxItem<String> _getItemByPixivisionId(int id) {
    final text = 'Pixivision Id: ${id}';
    return _buildItem(
      title: 'Pixivision Id',
      subtitle: id.toString(),
      onSelected: () => Leader.push(
        context,
        SoupPage(
          url: "https://www.pixivision.net/zh/a/${id}",
          spotlight: null,
        ),
        icon: const Icon(FluentIcons.image_pixel),
        title: Text(text),
      ),
    );
  }
}
