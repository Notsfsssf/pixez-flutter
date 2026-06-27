part of 'pixez_search_box.dart';

class _NextPixEzSearchBoxItem
    extends AutoSuggestBoxItem<_NextPixEzSearchBoxItemValue> {
  _NextPixEzSearchBoxItem({required super.value, required super.label});

  factory _NextPixEzSearchBoxItem.cleanHistory(BuildContext context) =>
      _NextPixEzSearchBoxItem(
        value: _ClearTagsPersistsItemValue(),
        label: I18n.of(context).clear_search_tag_history,
      );
  factory _NextPixEzSearchBoxItem.tagsPersist(
    BuildContext context,
    TagsPersist tags,
  ) => _NextPixEzSearchBoxItem(
    value: _TagsPersistItemValue(tags),
    label: '${tags.name} ${tags.translatedName}',
  );
  factory _NextPixEzSearchBoxItem.trendTags(
    BuildContext context,
    TrendTags tags,
  ) => _NextPixEzSearchBoxItem(
    value: _TrendTagsItemValue(tags),
    label: '#${tags.tag} ${tags.translatedName}',
  );
  factory _NextPixEzSearchBoxItem.tags(BuildContext context, Tags tags) =>
      _NextPixEzSearchBoxItem(
        value: _TagsItemValue(tags),
        label: '${tags.name} ${tags.translated_name}',
      );
  factory _NextPixEzSearchBoxItem.illustId(BuildContext context, int id) =>
      _NextPixEzSearchBoxItem(
        value: _IllustIdItemValue(id),
        label: id.toString(),
      );
  factory _NextPixEzSearchBoxItem.painterId(BuildContext context, int id) =>
      _NextPixEzSearchBoxItem(
        value: _PainterIdItemValue(id),
        label: id.toString(),
      );
  factory _NextPixEzSearchBoxItem.pixivisionId(BuildContext context, int id) =>
      _NextPixEzSearchBoxItem(
        value: _PixivisionIdItemValue(id),
        label: id.toString(),
      );
}

abstract class _NextPixEzSearchBoxItemValue {}

class _ClearTagsPersistsItemValue extends _NextPixEzSearchBoxItemValue {}

class _TagsPersistItemValue extends _NextPixEzSearchBoxItemValue {
  final TagsPersist data;

  _TagsPersistItemValue(this.data);
}

class _TrendTagsItemValue extends _NextPixEzSearchBoxItemValue {
  final TrendTags data;

  _TrendTagsItemValue(this.data);
}

class _TagsItemValue extends _NextPixEzSearchBoxItemValue {
  final Tags data;

  _TagsItemValue(this.data);
}

class _IllustIdItemValue extends _NextPixEzSearchBoxItemValue {
  final int id;

  _IllustIdItemValue(this.id);
}

class _PainterIdItemValue extends _NextPixEzSearchBoxItemValue {
  final int id;

  _PainterIdItemValue(this.id);
}

class _PixivisionIdItemValue extends _NextPixEzSearchBoxItemValue {
  final int id;

  _PixivisionIdItemValue(this.id);
}
