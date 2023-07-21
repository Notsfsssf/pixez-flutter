import 'package:bot_toast/bot_toast.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:pixez/component/fluent/pixez_button.dart';
import 'package:pixez/component/fluent/pixiv_image.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/tags.dart';
import 'package:pixez/models/trend_tags.dart';
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
  final TextEditingController _controller = TextEditingController();
  final SuggestionStore _suggestionStore = SuggestionStore();
  final SauceStore _sauceStore = SauceStore();
  final TrendTagsStore _trendTagsStore = TrendTagsStore();
  final List<String> tagGroup = [];
  List<AutoSuggestBoxItem<_SuggestItem>> _items = [];
  bool _isLoading = false;

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

    super.initState();
    _updateSuggestList();
  }

  @override
  Widget build(BuildContext context) {
    return AutoSuggestBox<_SuggestItem>(
      items: _items,
      controller: _controller,
      onChanged: _onAutoSuggestBoxChanged,
      onSelected: _onAutoSuggestBoxSelected,
      placeholder: I18n.of(context).search,
      leadingIcon: IconButton(
        icon: const Icon(FluentIcons.image_search),
        onPressed: _sauceStore.findImage,
      ),
      trailingIcon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isLoading)
            SizedBox(
              width: 16,
              height: 16,
              child: ProgressRing(
                strokeWidth: 3.0,
              ),
            ),
          IconButton(
            icon: const Icon(FluentIcons.search),
            onPressed: () => Leader.push(
              context,
              ResultPage(word: _controller.text),
              icon: const Icon(FluentIcons.search),
              title: Text('搜索 ${_controller.text}'),
            ),
          )
        ],
      ),
    );
  }

  Future _updateSuggestList() async {
    final text = _controller.text;
    _items.clear();
    _isLoading = true;
    setState(() {});
    try {
      if (text.isEmpty) {
        await tagHistoryStore.fetch();
        if (tagHistoryStore.tags.isEmpty) return;

        _items.addAll([
          _getCleanHistoryItem(),
          ...tagHistoryStore.tags.map(_getItemByTagsPersist),
        ]);
      } else if (text == '#') {
        await _trendTagsStore.fetch();

        _items.addAll(_trendTagsStore.trendTags.map(_getItemByTrendTags));
      } else {
        final id = int.tryParse(text);
        if (id != null)
          _items.addAll([
            _getItemByIllustId(id),
            _getItemByPainterId(id),
            _getItemByPixivisionId(id),
          ]);

        await _suggestionStore.fetch(text);
        final autoWords = _suggestionStore.autoWords;
        if (autoWords != null)
          _items.addAll(autoWords.tags.map(_getItemByTags).toList());
      }
    } finally {
      _isLoading = false;
      // HACK: 通知 AutoSuggestBox 使内部的 ListView 更新
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      _controller.notifyListeners();
      setState(() {});
    }
  }

  void _onAutoSuggestBoxChanged(String text, TextChangedReason reason) {
    if (reason == TextChangedReason.suggestionChosen) {
      _controller.clear();
      setState(() {});
      return;
    }

    _updateSuggestList();
  }

  AutoSuggestBoxItem<_SuggestItem> _buildItem({
    required String title,
    required _SuggestItem value,
    String? subtitle = null,
    Widget? leading = null,
    void Function()? onSelected,
    bool reverse = false,
  }) {
    return AutoSuggestBoxItem<_SuggestItem>(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null)
            Padding(
              padding: EdgeInsets.only(right: 4.0),
              child: leading,
            ),
          Text(
            subtitle != null && subtitle.isNotEmpty && reverse
                ? subtitle
                : title,
            style: reverse
                ? null
                : FluentTheme.of(context).typography.body?.copyWith(
                      color: FluentTheme.of(context).accentColor,
                    ),
          ),
          if (subtitle != null && subtitle.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(left: 4.0),
              child: Text(
                reverse ? title : subtitle,
                style: reverse
                    ? FluentTheme.of(context).typography.body?.copyWith(
                          color: FluentTheme.of(context).accentColor,
                        )
                    : null,
              ),
            ),
        ],
      ),
      label: title,
      value: value,
      onSelected: onSelected,
    );
  }

  Widget _buildTagImage(TrendTags tags) {
    return PixEzButton(
      noPadding: true,
      child: PixivImage(
        tags.illust.imageUrls.squareMedium,
        fit: BoxFit.cover,
        height: 26,
      ),
      onPressed: () {
        Leader.push(
          context,
          IllustLightingPage(id: tags.illust.id),
          icon: Icon(FluentIcons.picture),
          title: Text(
            I18n.of(context).illust_id + ': ${tags.illust.id}',
          ),
        );
      },
    );
  }

  AutoSuggestBoxItem<_SuggestItem> _getCleanHistoryItem() {
    return _buildItem(
      title: I18n.of(context).clear_search_tag_history,
      value: _SuggestItem(type: _SuggestItemType.cleanHistory),
    );
  }

  AutoSuggestBoxItem<_SuggestItem> _getItemByTagsPersist(TagsPersist tags) {
    return _buildItem(
      title: tags.name,
      subtitle: tags.translatedName,
      value: _SuggestItem(
        word: tags.name,
        translated: tags.translatedName,
      ),
    );
  }

  AutoSuggestBoxItem<_SuggestItem> _getItemByTrendTags(TrendTags tags) {
    return _buildItem(
      title: "#${tags.tag}",
      subtitle: tags.translatedName,
      leading: _buildTagImage(tags),
      value: _SuggestItem(
        word: tags.tag,
        translated: tags.translatedName,
      ),
    );
  }

  AutoSuggestBoxItem<_SuggestItem> _getItemByTags(Tags tags) {
    return _buildItem(
      title: tags.name,
      subtitle: tags.translated_name,
      value: _SuggestItem(
        word: tags.name,
        translated: tags.translated_name,
      ),
    );
  }

  AutoSuggestBoxItem<_SuggestItem> _getItemByIllustId(int id) {
    return _buildItem(
      reverse: true,
      title: id.toString(),
      subtitle: I18n.of(context).illust_id,
      value: _SuggestItem(
        type: _SuggestItemType.illustId,
        id: id,
      ),
    );
  }

  AutoSuggestBoxItem<_SuggestItem> _getItemByPainterId(int id) {
    return _buildItem(
      reverse: true,
      title: id.toString(),
      subtitle: I18n.of(context).painter_id,
      value: _SuggestItem(
        type: _SuggestItemType.painterId,
        id: id,
      ),
    );
  }

  AutoSuggestBoxItem<_SuggestItem> _getItemByPixivisionId(int id) {
    return _buildItem(
      reverse: true,
      title: id.toString(),
      subtitle: 'Pixivision Id',
      value: _SuggestItem(
        type: _SuggestItemType.pixivisionId,
        id: id,
      ),
    );
  }

  void _onAutoSuggestBoxSelected(AutoSuggestBoxItem<_SuggestItem> value) {
    final item = value.value;
    if (item == null) return;
    switch (item.type) {
      case _SuggestItemType.normal:
      case _SuggestItemType.tag:
        if (tagGroup.length > 1) {
          tagGroup.last = item.word!;
          final text = tagGroup.join(" ");
          _controller.text = text;
          _controller.selection = TextSelection.fromPosition(
            TextPosition(offset: text.length),
          );
          setState(() {});
          return;
        }
      default:
    }
    FocusScope.of(context).unfocus();
    switch (item.type) {
      case _SuggestItemType.normal:
      case _SuggestItemType.tag:
        final prefix = item.type == _SuggestItemType.tag ? '#' : '';
        Leader.push(
          context,
          ResultPage(
            word: item.word!,
            translatedName: item.translated ?? '',
          ),
          icon: Icon(FluentIcons.search),
          title: Text('${I18n.of(context).search}: ${prefix}${item.word}'),
        );
      case _SuggestItemType.illustId:
        Leader.push(
          context,
          IllustLightingPage(id: item.id!),
          icon: const Icon(FluentIcons.image_pixel),
          title: Text('${I18n.of(context).illust_id}: ${item.id}'),
        );
      case _SuggestItemType.painterId:
        Leader.push(
          context,
          UsersPage(id: item.id!),
          icon: const Icon(FluentIcons.image_pixel),
          title: Text('${I18n.of(context).painter_id}: ${item.id}'),
        );
      case _SuggestItemType.pixivisionId:
        Leader.push(
          context,
          SoupPage(
            url: "https://www.pixivision.net/zh/a/${item.id}",
            spotlight: null,
          ),
          icon: const Icon(FluentIcons.image_pixel),
          title: Text('Pixivision Id: ${item.id}'),
        );
      case _SuggestItemType.cleanHistory:
        showDialog(
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
        );
      default:
    }
  }
}

enum _SuggestItemType {
  normal,
  tag,
  illustId,
  painterId,
  pixivisionId,
  cleanHistory,
}

class _SuggestItem {
  final _SuggestItemType type;
  final String? word;
  final String? translated;
  final int? id;

  const _SuggestItem({
    this.type = _SuggestItemType.normal,
    this.word = null,
    this.translated = null,
    this.id = null,
  });
}
