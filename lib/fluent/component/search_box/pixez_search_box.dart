import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:fluent_ui/fluent_ui.dart';
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
  final GlobalKey<AutoSuggestBoxState<_PixEzSearchBoxItem>> _key =
      GlobalKey<AutoSuggestBoxState<_PixEzSearchBoxItem>>();
  final TextEditingController _controller = TextEditingController();
  final SuggestionStore _suggestionStore = SuggestionStore();
  final SauceStore _sauceStore = SauceStore();
  final TrendTagsStore _trendTagsStore = TrendTagsStore();
  final FocusNode _focusNode = FocusNode();
  final List<_PixEzSearchItem> _items = [];
  bool _isLoading = false;
  _PixEzSearchItem? _cache;

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
        BotToast.showText(text: I18n.ofContext().no_result);
      }
    });
    _focusNode.addListener(() {
      if (_focusNode.hasFocus && _key.currentState?.isOverlayVisible == false) {
        if (_controller.text.isEmpty) _updateSuggestList();
        _key.currentState?.showOverlay();
      } else if (_key.currentState?.isOverlayVisible == true) {
        _key.currentState?.dismissOverlay();
      }
    });

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
    return AutoSuggestBox<_PixEzSearchBoxItem>(
      key: _key,
      items: _items,
      controller: _controller,
      focusNode: _focusNode,
      onChanged: _onAutoSuggestBoxChanged,
      onSelected: _onAutoSuggestBoxSelected,
      placeholder: I18n.of(context).search_word_hint,
      leadingIcon: Tooltip(
        message: '以图搜源',
        child: IconButton(
          icon: const Icon(FluentIcons.image_search),
          onPressed: _sauceStore.findImage,
        ),
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
              ResultPage(word: _controller.text.trim()),
              icon: const Icon(FluentIcons.search),
              title: Text('搜索 ${_controller.text.trim()}'),
            ),
          )
        ],
      ),
    );
  }

  Timer? _delay;
  void _notifyFinished() {
    _isLoading = false;
    // HACK: 通知 AutoSuggestBox 使内部的 ListView 更新
    try {
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      _controller.notifyListeners();
    } catch (e) {}
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _updateSuggestList() async {
    final text = _controller.text;
    _isLoading = true;
    if (mounted) setState(() {});
    if (text.isEmpty) {
      // 如果搜索框为空则展示历史记录
      await tagHistoryStore.fetch();

      _items.clear();
      // 历史记录为空则不展示
      if (tagHistoryStore.tags.isEmpty) {
        _notifyFinished();
        return;
      }
      _items.add(_PixEzSearchItem.cleanHistory(context));
      _items.addAll(tagHistoryStore.tags
          .map((i) =>
              _PixEzSearchItem.tagsPersist(context, i, _updateSuggestList))
          .toList());

      _notifyFinished();
    } else if (text.startsWith('#')) {
      // 如果搜索框以 # 开头则展示趋势标签
      // 如果不是单独的 # 符号 则用户可能想要筛选标签结果
      // 此时不对列表做修改
      if (text != '#') return;

      final future = _trendTagsStore.fetch();
      if (_trendTagsStore.trendTags.isEmpty) await future;

      _items.clear();
      _items.addAll(_trendTagsStore.trendTags
          .map((i) => _PixEzSearchItem.trendTags(context, i))
          .toList());
      _notifyFinished();
    } else {
      _items.clear();
      // 如果输入了数字则展示快速跳转
      final id = int.tryParse(text);
      if (id != null) {
        _items.add(_PixEzSearchItem.illustId(context, id));
        _items.add(_PixEzSearchItem.painterId(context, id));
        _items.add(_PixEzSearchItem.pixivisionId(context, id));
        _notifyFinished();
      }

      // 取消挂起的异步搜索
      _delay?.cancel();
      // 创建新的异步搜索
      _delay = Timer(const Duration(seconds: 1), () async {
        // 按空格分割字符串 并使用最后一个字符串作为关键词搜索匹配的标签
        // 如果最后一个是空格则不展示内容
        if (text.endsWith(' ')) return;
        final arr = text.split(' ');

        await _suggestionStore.fetch(arr.last);
        final tags = _suggestionStore.autoWords?.tags ?? const [];
        if (tags.isEmpty) return;

        _items.addAll(
            tags.map((i) => _PixEzSearchItem.tags(context, i, text)).toList());
        _notifyFinished();
      });
    }
  }

  void _onAutoSuggestBoxChanged(String text, TextChangedReason reason) {
    if (reason != TextChangedReason.suggestionChosen) {
      _updateSuggestList();
      return;
    }

    if (_cache?.value?.type != _PixEzSearchBoxItemType.tag) return;
    var text = _controller.text;
    final arr = text.split(' ');
    text = text.substring(0, text.length - arr.last.length);
    if (!text.endsWith(' ')) text += ' ';
    text = text.trimLeft();
    text += _cache!.value!.word!;
    text += ' ';
    _controller
      ..text = text
      ..selection = TextSelection.collapsed(
        offset: text.length,
      );
  }

  void _onAutoSuggestBoxSelected(
      AutoSuggestBoxItem<_PixEzSearchBoxItem> value) {
    _cache = value as _PixEzSearchItem?;
    final item = value.value;
    if (item == null) return;
    if (item.type == _PixEzSearchBoxItemType.tag) return;

    FocusScope.of(context).unfocus();
    switch (item.type) {
      case _PixEzSearchBoxItemType.history:
        Leader.push(
          context,
          ResultPage(
            word: item.word!,
            translatedName: item.translated ?? '',
          ),
          icon: Icon(FluentIcons.search),
          title: Text('${I18n.of(context).search}: ${item.word}'),
        );
      case _PixEzSearchBoxItemType.illustId:
        Leader.push(
          context,
          IllustLightingPage(id: item.id!),
          icon: const Icon(FluentIcons.image_pixel),
          title: Text('${I18n.of(context).illust_id}: ${item.id}'),
        );
      case _PixEzSearchBoxItemType.painterId:
        Leader.push(
          context,
          UsersPage(id: item.id!),
          icon: const Icon(FluentIcons.image_pixel),
          title: Text('${I18n.of(context).painter_id}: ${item.id}'),
        );
      case _PixEzSearchBoxItemType.pixivisionId:
        Leader.push(
          context,
          SoupPage(
            url: "https://www.pixivision.net/zh/a/${item.id}",
            spotlight: null,
          ),
          icon: const Icon(FluentIcons.image_pixel),
          title: Text('Pixivision Id: ${item.id}'),
        );
      case _PixEzSearchBoxItemType.cleanHistory:
        showDialog(
          context: context,
          builder: (context) {
            return ContentDialog(
              title: Text(I18n.of(context).clean_history),
              actions: [
                Button(
                  onPressed: Navigator.of(context).pop,
                  child: Text(I18n.of(context).cancel),
                ),
                FilledButton(
                  onPressed: () async {
                    await tagHistoryStore.deleteAll();
                    _controller.clear();
                    await _updateSuggestList();
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
