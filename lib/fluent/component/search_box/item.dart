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

class _PixEzSearchItem {
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

  static AutoSuggestBoxItem<_PixEzSearchBoxItem> _buildItem({
    required BuildContext context,
    required String title,
    required _PixEzSearchBoxItem value,
    String? subtitle = null,
    Widget? leading = null,
    Widget? trailing = null,
    void Function()? onSelected,
    bool reverse = false,
  }) {
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

    return AutoSuggestBoxItem<_PixEzSearchBoxItem>(
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
      label: "$title $subtitle",
      value: value,
      onSelected: onSelected,
    );
  }

  /// 清空历史记录
  static AutoSuggestBoxItem<_PixEzSearchBoxItem> cleanHistoryItem(
      BuildContext context) {
    return _buildItem(
      context: context,
      leading: Icon(FluentIcons.delete),
      title: I18n.of(context).clear_search_tag_history,
      value: _PixEzSearchBoxItem(type: _PixEzSearchBoxItemType.cleanHistory),
    );
  }

  static AutoSuggestBoxItem<_PixEzSearchBoxItem> tagsPersist(
      BuildContext context, TagsPersist tags, void Function() refresh) {
    final item = _buildItem(
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
          if (tags.id != null) tagHistoryStore.delete(tags.id!);
          refresh();
        },
      ),
    );
    return item;
  }

  static AutoSuggestBoxItem<_PixEzSearchBoxItem> trendTags(
      BuildContext context, TrendTags tags) {
    return _buildItem(
      context: context,
      title: "#${tags.tag}",
      subtitle: tags.translatedName != null ? "#${tags.translatedName}" : null,
      leading: _buildTagImage(context, tags),
      value: _PixEzSearchBoxItem(
        word: tags.tag,
        translated: tags.translatedName,
      ),
    );
  }

  static AutoSuggestBoxItem<_PixEzSearchBoxItem> tags(
      BuildContext context, Tags tags) {
    return _buildItem(
      context: context,
      title: tags.name,
      subtitle: tags.translated_name,
      value: _PixEzSearchBoxItem(
        word: tags.name,
        translated: tags.translated_name,
      ),
    );
  }

  static AutoSuggestBoxItem<_PixEzSearchBoxItem> illustId(
      BuildContext context, int id) {
    return _buildItem(
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

  static AutoSuggestBoxItem<_PixEzSearchBoxItem> painterId(
      BuildContext context, int id) {
    return _buildItem(
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

  static AutoSuggestBoxItem<_PixEzSearchBoxItem> pixivisionId(
      BuildContext context, int id) {
    return _buildItem(
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
