part of 'pixez_search_box.dart';

enum _PixEzSearchBoxItemType {
  normal,
  history,
  tag,
  illustId,
  painterId,
  pixivisionId,
  cleanHistory,
}

class _PixEzSearchBoxItem {
  final _PixEzSearchBoxItemType type;
  final String? word;
  final String? translated;
  final int? id;

  const _PixEzSearchBoxItem({
    this.type = _PixEzSearchBoxItemType.normal,
    this.word = null,
    this.translated = null,
    this.id = null,
  });
}

class _PixEzSearchItem extends AutoSuggestBoxItem<_PixEzSearchBoxItem> {
  _PixEzSearchItem({
    required super.value,
    required super.label,
    super.child,
    super.onSelected,
  });

  static Widget _buildTagImage(BuildContext context, TrendTags tags) {
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

  factory _PixEzSearchItem.build({
    required BuildContext context,
    required String title,
    required _PixEzSearchBoxItem value,
    String? label = null,
    String? subtitle = null,
    Widget? leading = null,
    Widget? trailing = null,
    void Function()? onSelected,
    bool reverse = false,
  }) {
    label ??= '$title $subtitle';

    var text = [
      TextSpan(
        text: title,
        style: FluentTheme.of(context).typography.body?.copyWith(
              color: FluentTheme.of(context).accentColor,
            ),
      ),
      TextSpan(
        text: ' ',
        style: null,
      ),
      TextSpan(
        text: subtitle,
        style: null,
      )
    ];

    if (reverse && subtitle != null) text = text.reversed.toList();

    return _PixEzSearchItem(
      child: Row(
        children: [
          if (leading != null)
            Padding(
              padding: EdgeInsets.only(right: 4.0),
              child: leading,
            ),
          Expanded(
            child: Tooltip(
              richMessage: TextSpan(
                children: text,
              ),
              child: Text.rich(
                TextSpan(
                  children: text,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          if (trailing != null)
            Padding(
              padding: EdgeInsets.only(left: 4.0),
              child: trailing,
            ),
        ],
      ),
      label: label,
      value: value,
      onSelected: onSelected,
    );
  }

  /// 清空历史记录
  factory _PixEzSearchItem.cleanHistory(BuildContext context) {
    return _PixEzSearchItem.build(
      context: context,
      leading: Icon(FluentIcons.delete),
      title: I18n.of(context).clear_search_tag_history,
      value: _PixEzSearchBoxItem(
        type: _PixEzSearchBoxItemType.cleanHistory,
      ),
    );
  }
  factory _PixEzSearchItem.tagsPersist(
      BuildContext context, TagsPersist tags, void Function() refresh) {
    return _PixEzSearchItem.build(
      context: context,
      title: tags.name,
      subtitle: tags.translatedName,
      value: _PixEzSearchBoxItem(
        type: _PixEzSearchBoxItemType.history,
        word: tags.name,
        translated: tags.translatedName,
      ),
      trailing: PixEzButton(
        child: Icon(FluentIcons.chrome_close),
        onPressed: () {
          assert(tags.id != null);
          tagHistoryStore.delete(tags.id!);
          refresh();
        },
      ),
    );
  }

  factory _PixEzSearchItem.trendTags(BuildContext context, TrendTags tags) {
    return _PixEzSearchItem.build(
      context: context,
      title: '#${tags.tag}',
      subtitle: tags.translatedName != null ? '#${tags.translatedName}' : null,
      leading: _buildTagImage(context, tags),
      value: _PixEzSearchBoxItem(
        word: tags.tag,
        translated: tags.translatedName,
      ),
    );
  }

  factory _PixEzSearchItem.tags(BuildContext context, Tags tags, String text) {
    return _PixEzSearchItem.build(
      context: context,
      title: tags.name,
      subtitle: tags.translated_name,
      label: text,
      value: _PixEzSearchBoxItem(
        word: tags.name,
        translated: tags.translated_name,
        type: _PixEzSearchBoxItemType.tag,
      ),
    );
  }
  factory _PixEzSearchItem.illustId(BuildContext context, int id) {
    return _PixEzSearchItem.build(
      context: context,
      reverse: true,
      title: id.toString(),
      subtitle: I18n.of(context).illust_id,
      value: _PixEzSearchBoxItem(
        type: _PixEzSearchBoxItemType.illustId,
        id: id,
      ),
    );
  }

  factory _PixEzSearchItem.painterId(BuildContext context, int id) {
    return _PixEzSearchItem.build(
      context: context,
      reverse: true,
      title: id.toString(),
      subtitle: I18n.of(context).painter_id,
      value: _PixEzSearchBoxItem(
        type: _PixEzSearchBoxItemType.painterId,
        id: id,
      ),
    );
  }

  factory _PixEzSearchItem.pixivisionId(BuildContext context, int id) {
    return _PixEzSearchItem.build(
      context: context,
      reverse: true,
      title: id.toString(),
      subtitle: 'Pixivision Id',
      value: _PixEzSearchBoxItem(
        type: _PixEzSearchBoxItemType.pixivisionId,
        id: id,
      ),
    );
  }
}
