import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:pixez/fluent/component/pixez_button.dart';
import 'package:pixez/fluent/component/pixiv_image.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/tags.dart';
import 'package:pixez/models/trend_tags.dart';
import 'package:pixez/fluent/page/picture/illust_lighting_page.dart';
import 'package:pixez/fluent/page/search/result_page.dart';
import 'package:pixez/fluent/page/soup/soup_page.dart';
import 'package:pixez/fluent/page/user/users_page.dart';
import 'package:pixez/page/saucenao/sauce_store.dart';
import 'package:pixez/page/search/suggest/suggestion_store.dart';
import 'package:pixez/page/search/trend_tags_store.dart';

part 'item.dart';

class PixEzSearchBox extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _PixEzSearchBoxState();
}

class _PixEzSearchBoxState extends State<StatefulWidget> {
  final SuggestionStore _suggestionStore = SuggestionStore();
  final SauceStore _sauceStore = SauceStore();
  final TrendTagsStore _trendTagsStore = TrendTagsStore();

  final _key = GlobalKey<AutoSuggestBoxState<_NextPixEzSearchBoxItem>>();
  final List<_NextPixEzSearchBoxItem> _items = [];
  final List<Tags> _selectedTags = [];
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _loading = false;

  @override
  void initState() {
    _sauceStore.observableStream.listen(_searchByImage);
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        if (_key.currentState?.isOverlayVisible == true)
          _key.currentState?.dismissOverlay();
        return;
      }

      _updateSuggestList(context);
      _key.currentState?.showOverlay();
    });

    _updateSuggestList(context);
    super.initState();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    _sauceStore.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget widget = AutoSuggestBox<_NextPixEzSearchBoxItemValue>(
      key: _key,
      controller: _controller,
      items: _items,
      itemBuilder: _buildItem,
      onSelected: _onAutoSuggestBoxSelected,
      onChanged: _onAutoSuggestBoxChanged,
      leadingIcon: _buildLeading(context),
      placeholder: I18n.of(context).search_word_hint,
      trailingIcon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_loading)
            SizedBox(
              width: 16,
              height: 16,
              child: ProgressRing(strokeWidth: 3.0),
            ),
          IconButton(icon: const Icon(FluentIcons.search), onPressed: _search),
        ],
      ),
    );

    widget = KeyboardListener(
      focusNode: _focusNode,
      child: widget,
      onKeyEvent: (e) {
        switch (e.logicalKey) {
          case LogicalKeyboardKey.enter:
          case LogicalKeyboardKey.numpadEnter:
            _search();
            break;
          default:
        }
      },
    );

    return widget;
  }

  Widget _buildLeading(BuildContext context) {
    if (_selectedTags.isEmpty)
      return Tooltip(
        message: '以图搜源',
        child: IconButton(
          icon: const Icon(FluentIcons.image_search),
          onPressed: _sauceStore.findImage,
        ),
      );

    return Row(
      children: [
        for (var i in _selectedTags)
          Button(
            child: Text(i.name),
            onPressed: () {
              _selectedTags.remove(i);
            },
          ),
      ],
    );
  }

  Widget _title(BuildContext context, Widget widget) {
    return DefaultTextStyle.merge(
      style: (FluentTheme.of(context).typography.body ?? const TextStyle()),
      child: widget,
    );
  }

  Widget _buildItem(
    BuildContext context,
    AutoSuggestBoxItem<_NextPixEzSearchBoxItemValue> item,
  ) {
    switch (item.value) {
      case _ClearTagsPersistsItemValue _:
        return Tooltip(
          message: I18n.of(context).clear_search_tag_history,
          child: ListTile(
            leading: Icon(FluentIcons.full_history),
            title: Text(
              I18n.of(context).clear_search_tag_history,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Icon(FluentIcons.delete),
            onPressed: () => _onAutoSuggestBoxSelected(item),
          ),
        );
      case _TagsPersistItemValue tagsPersistItem:
        final text = TextSpan(
          children: [
            TextSpan(
              text: tagsPersistItem.data.name,
              style: FluentTheme.of(context).typography.body?.copyWith(
                color: FluentTheme.of(context).accentColor,
              ),
            ),
            const TextSpan(text: ' '),
            TextSpan(
              text: tagsPersistItem.data.translatedName,
              style: FluentTheme.of(context).typography.body,
            ),
          ],
        );
        return Tooltip(
          richMessage: text,
          child: ListTile(
            leading: Icon(FluentIcons.history),
            title: Text.rich(text, overflow: TextOverflow.ellipsis),
            trailing: tagsPersistItem.data.id != null
                ? Tooltip(
                    message: 'Remove History',
                    child: PixEzButton(
                      child: Icon(FluentIcons.delete),
                      noPadding: true,
                      onPressed: () {
                        tagHistoryStore.delete(tagsPersistItem.data.id!);
                        _updateSuggestList(context);
                      },
                    ),
                  )
                : null,
            onPressed: () => _onAutoSuggestBoxSelected(item),
          ),
        );
      case _TrendTagsItemValue trendTagsItemValue:
        final text = TextSpan(
          children: [
            TextSpan(
              text: trendTagsItemValue.data.tag,
              style: FluentTheme.of(context).typography.body?.copyWith(
                color: FluentTheme.of(context).accentColor,
              ),
            ),
            const TextSpan(text: ' '),
            TextSpan(
              text: trendTagsItemValue.data.translatedName,
              style: FluentTheme.of(context).typography.body,
            ),
          ],
        );
        final title =
            I18n.of(context).illust_id +
            ': ${trendTagsItemValue.data.illust.id}';
        return Tooltip(
          richMessage: text,
          child: ListTile(
            leading: PixEzButton(
              noPadding: true,
              toolTips: title,
              child: PixivImage(
                trendTagsItemValue.data.illust.imageUrls.squareMedium,
                fit: BoxFit.cover,
                height: 26,
              ),
              onPressed: () {
                Leader.push(
                  context,
                  IllustLightingPage(id: trendTagsItemValue.data.illust.id),
                  icon: Icon(FluentIcons.picture),
                  title: _title(context, Text(title)),
                );
              },
            ),
            title: Text.rich(text, overflow: TextOverflow.ellipsis),
            onPressed: () => _onAutoSuggestBoxSelected(item),
          ),
        );
      case _TagsItemValue tagsItemValue:
        final text = TextSpan(
          children: [
            TextSpan(
              text: tagsItemValue.data.name,
              style: FluentTheme.of(context).typography.body?.copyWith(
                color: FluentTheme.of(context).accentColor,
              ),
            ),
            const TextSpan(text: ' '),
            TextSpan(
              text: tagsItemValue.data.translated_name,
              style: FluentTheme.of(context).typography.body,
            ),
          ],
        );
        return Tooltip(
          richMessage: text,
          child: ListTile(
            title: Text.rich(text, overflow: TextOverflow.ellipsis),
            onPressed: () => _onAutoSuggestBoxSelected(item),
          ),
        );
      case _IllustIdItemValue illustIdItemValue:
        final text = TextSpan(
          children: [
            TextSpan(text: I18n.of(context).illust_id),
            const TextSpan(text: ' '),
            TextSpan(
              text: illustIdItemValue.id.toString(),
              style: FluentTheme.of(context).typography.body?.copyWith(
                color: FluentTheme.of(context).accentColor,
              ),
            ),
          ],
        );
        return Tooltip(
          richMessage: text,
          child: ListTile(
            title: Text.rich(text, overflow: TextOverflow.ellipsis),
            onPressed: () => _onAutoSuggestBoxSelected(item),
          ),
        );
      case _PainterIdItemValue painterIdItemValue:
        final text = TextSpan(
          children: [
            TextSpan(text: I18n.of(context).painter_id),
            const TextSpan(text: ' '),
            TextSpan(
              text: painterIdItemValue.id.toString(),
              style: FluentTheme.of(context).typography.body?.copyWith(
                color: FluentTheme.of(context).accentColor,
              ),
            ),
          ],
        );
        return Tooltip(
          richMessage: text,
          child: ListTile(
            title: Text.rich(text, overflow: TextOverflow.ellipsis),
            onPressed: () => _onAutoSuggestBoxSelected(item),
          ),
        );
      case _PixivisionIdItemValue pixivisionIdItemValue:
        final text = TextSpan(
          children: [
            const TextSpan(text: 'Pixivision Id'),
            const TextSpan(text: ' '),
            TextSpan(
              text: pixivisionIdItemValue.id.toString(),
              style: FluentTheme.of(context).typography.body?.copyWith(
                color: FluentTheme.of(context).accentColor,
              ),
            ),
          ],
        );
        return Tooltip(
          richMessage: text,
          child: ListTile(
            title: Text.rich(text, overflow: TextOverflow.ellipsis),
            onPressed: () => _onAutoSuggestBoxSelected(item),
          ),
        );
      default:
        return Tooltip(
          message: item.label,
          child: ListTile(
            title: _title(context, Text(item.label)),
            onPressed: () => _onAutoSuggestBoxSelected(item),
          ),
        );
    }
  }

  void _onAutoSuggestBoxSelected(
    AutoSuggestBoxItem<_NextPixEzSearchBoxItemValue> item,
  ) {
    switch ((item as _NextPixEzSearchBoxItem?)?.value) {
      case _ClearTagsPersistsItemValue _:
        showDialog(
          context: context,
          builder: (context) => ContentDialog(
            title: _title(context, Text(I18n.of(context).clean_history)),
            actions: [
              Button(
                onPressed: Navigator.of(context).pop,
                child: Text(I18n.of(context).cancel),
              ),
              FilledButton(
                onPressed: () async {
                  await tagHistoryStore.deleteAll();
                  _controller.clear();
                  _items.clear();
                  Navigator.of(context).pop();
                },
                child: Text(I18n.of(context).ok),
              ),
            ],
          ),
        );
        break;
      case _TagsPersistItemValue tagsPersistItem:
        Leader.push(
          context,
          ResultPage(
            word: tagsPersistItem.data.name,
            translatedName: tagsPersistItem.data.translatedName,
          ),
          icon: Icon(FluentIcons.search),
          title: Text(
            '${I18n.of(context).search}: ${tagsPersistItem.data.name}',
          ),
        );
        break;
      case _IllustIdItemValue illustIdItemValue:
        Leader.push(
          context,
          IllustLightingPage(id: illustIdItemValue.id),
          icon: const Icon(FluentIcons.image_pixel),
          title: Text('${I18n.of(context).illust_id}: ${illustIdItemValue.id}'),
        );
        break;
      case _PainterIdItemValue painterIdItemValue:
        Leader.push(
          context,
          UsersPage(id: painterIdItemValue.id),
          icon: const Icon(FluentIcons.image_pixel),
          title: Text(
            '${I18n.of(context).painter_id}: ${painterIdItemValue.id}',
          ),
        );
        break;
      case _PixivisionIdItemValue pixivisionIdItemValue:
        Leader.push(
          context,
          SoupPage(
            url: "https://www.pixivision.net/zh/a/${pixivisionIdItemValue.id}",
            spotlight: null,
          ),
          icon: const Icon(FluentIcons.image_pixel),
          title: Text('Pixivision Id: ${pixivisionIdItemValue.id}'),
        );
        break;
      case _TagsItemValue tagsItemValue:
        _selectedTags.add(tagsItemValue.data);
        _controller.clear();
        setState(() {});
        break;
      case _TrendTagsItemValue trendTagsItemValue:
        Leader.push(
          context,
          ResultPage(
            word: trendTagsItemValue.data.tag,
            translatedName: trendTagsItemValue.data.translatedName ?? '',
          ),
          icon: const Icon(FluentIcons.search),
          title: Text('搜索 ${trendTagsItemValue.data.tag}'),
        );
        break;
      default:
        break;
    }
  }

  void _search() {
    var text = _controller.text.trim();
    if (text.isEmpty && _selectedTags.isEmpty) return;
    if (_selectedTags.isNotEmpty) {
      final tags = _selectedTags.map((i) => i.name).join(' ');
      text = '${tags} ${text}';
    }

    _selectedTags.clear();
    _controller.clear();

    Leader.push(
      context,
      ResultPage(word: text),
      icon: const Icon(FluentIcons.search),
      title: Text('搜索 ${text}'),
    );
  }

  void _searchByImage(event) {
    if (event == null || !_sauceStore.results.isNotEmpty) {
      BotToast.showText(text: I18n.ofContext().no_result);
      return;
    }

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
  }

  Timer? _delay;
  void _updateSuggestList(BuildContext context) {
    final text = _controller.text;

    if (text.isEmpty) {
      _delay?.cancel();
      _delay = Timer(const Duration(seconds: 1), () async {
        setState(() => _loading = true);
        // 如果搜索框为空则展示历史记录
        await tagHistoryStore.fetch();
        if (tagHistoryStore.tags.isEmpty) {
          setState(() => _loading = false);
          return;
        }
        _items.clear();

        _items.add(_NextPixEzSearchBoxItem.cleanHistory(context));
        tagHistoryStore.tags.forEach(
          (tag) =>
              _items.add(_NextPixEzSearchBoxItem.tagsPersist(context, tag)),
        );

        _notifyFinished();
      });
    } else if (text.startsWith('#')) {
      // 如果搜索框以 # 开头则展示趋势标签

      // 如果不是单独的 # 符号 则用户可能想要筛选标签结果
      // 此时不对列表做修改
      if (text != '#') return;

      _delay?.cancel();
      _delay = Timer(const Duration(seconds: 1), () async {
        setState(() => _loading = true);
        await _trendTagsStore.fetch();
        if (_trendTagsStore.trendTags.isEmpty) {
          setState(() => _loading = false);
          return;
        }
        _items.clear();

        _trendTagsStore.trendTags.forEach(
          (tag) => _items.add(_NextPixEzSearchBoxItem.trendTags(context, tag)),
        );

        _notifyFinished();
      });
    } else {
      final id = int.tryParse(text);
      if (id != null) {
        _items.clear();
        _items.add(_NextPixEzSearchBoxItem.illustId(context, id));
        _items.add(_NextPixEzSearchBoxItem.painterId(context, id));
        _items.add(_NextPixEzSearchBoxItem.pixivisionId(context, id));
      }

      _delay?.cancel();
      _delay = Timer(const Duration(seconds: 1), () async {
        setState(() => _loading = true);
        await _suggestionStore.fetch(text);
        if (_suggestionStore.autoWords?.tags.isNotEmpty != true) {
          setState(() => _loading = false);
          return;
        }
        if (id == null) _items.clear();

        _suggestionStore.autoWords!.tags.forEach(
          (tag) => _items.add(_NextPixEzSearchBoxItem.tags(context, tag)),
        );

        _notifyFinished();
      });
    }

    setState(() {});
  }

  void _notifyFinished() {
    _loading = false;
    // HACK: 通知 AutoSuggestBox 使内部的 ListView 更新
    try {
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      _controller.notifyListeners();
    } catch (e) {}
    if (!mounted) return;
    setState(() {});
  }

  void _onAutoSuggestBoxChanged(String text, TextChangedReason reason) {
    if (reason != TextChangedReason.suggestionChosen) {
      _updateSuggestList(context);
      return;
    }
  }
}
