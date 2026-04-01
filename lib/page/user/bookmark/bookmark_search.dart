import 'dart:async' show Timer;

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/i18n.dart' show I18n;
import 'package:pixez/models/tags.dart' as suggestion_models;
import 'package:pixez/page/search/suggest/suggestion_store.dart'
    show SuggestionStore;

class BookMarkSearchController extends ChangeNotifier {}

class BookMarkSearchView extends StatefulWidget {
  BookMarkSearchView({
    this.suggestionDebounceTime = 250,
    this.onChange,
    this.controller,
    required this.tags,
  });
  final List<String> tags;
  final int suggestionDebounceTime;
  final BookMarkSearchController? controller;
  final void Function(List<String>)? onChange;

  @override
  State<StatefulWidget> createState() => _BookMarkSearchViewState();
}

class _BookMarkSearchViewState extends State<BookMarkSearchView> {
  Timer? _suggestionDebounceTimer;
  late final TextEditingController _textEditingController;

  int get suggestionDebounceTime => widget.suggestionDebounceTime;
  // The input text is derived from the controller so clearing the field and
  // hiding suggestions stay in sync.
  String get _searchInputValue => _textEditingController.text.trim();

  // search suggestion state SuggestionStore::autoWords is observable
  // SuggestionStore::fetch will perform a auto complete suggestion fetch and update the observable
  final SuggestionStore _suggestionStore = SuggestionStore();

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _textEditingController,
          decoration: InputDecoration(
            // input placeholder
            hintText: widget.tags.isEmpty
                ? I18n.of(context).bookmarkSearchTagInputHint
                : null,
            // selected tags are implemented as TextField's prefixIcon
            prefixIcon: widget.tags.isNotEmpty
                ? SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(left: 12.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (String tag in widget.tags)
                          _buildSearchTagIconPart(
                            context,
                            tag,
                            onTap: () {
                              widget.onChange?.call(
                                widget.tags
                                    .where((_tag) => _tag != tag)
                                    .toList(),
                              );
                            },
                          ),
                      ],
                    ),
                  )
                : const Padding(
                    padding: EdgeInsets.only(left: 12.0),
                    child: Icon(Icons.search),
                  ),
            prefixIconConstraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12.0,
              horizontal: 12.0,
            ),
          ),
          onChanged: (value) {
            _scheduleSuggestionFetch(value);
            setState(() {});
          },
          onSubmitted: (value) {
            _submitTag(value);
          },
        ),
        // Auto-complete tags display
        Observer(
          builder: (context) {
            // Suggestions are driven by SuggestionStore.autoWords updates.
            final suggestionTags =
                _suggestionStore.autoWords?.tags ??
                const <suggestion_models.Tags>[];
            if (_searchInputValue.isEmpty || suggestionTags.isEmpty) {
              return const SizedBox.shrink();
            }
            return Container(
              constraints: const BoxConstraints(maxHeight: 168),
              color: Colors.transparent,
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                itemCount: suggestionTags.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  indent: 12,
                  endIndent: 12,
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.35),
                ),
                itemBuilder: (BuildContext context, int index) =>
                    _buildSuggestionItem(
                      context,
                      suggestionTags[index],
                      onTap: () {
                        _submitTag(suggestionTags[index].name);
                      },
                    ),
              ),
            );
          },
        ),
      ],
    );
  }

  // should invoke whenever TextField's value changes
  // if query is not empty, it will trigger/refresh a debounced suggestion fetch
  // else, any currently debouncing fetch is canceled
  void _scheduleSuggestionFetch(String query) {
    _suggestionDebounceTimer?.cancel();
    query = query.trim();
    _suggestionStore.clear();
    if (query.isEmpty) {
      return;
    }
    _suggestionDebounceTimer = Timer(
      Duration(milliseconds: suggestionDebounceTime),
      () {
        // Ignore stale debounce callbacks after the user has edited or cleared
        // the field again.
        if (!mounted || _searchInputValue != query) {
          return;
        }
        _suggestionStore.fetch(query);
      },
    );
  }

  void _submitTag(String value) {
    final tag = value.trim();
    _suggestionDebounceTimer?.cancel();
    _suggestionStore.clear();
    _textEditingController.clear();
    setState(() {});
    // Empty and duplicate tags are ignored silently to keep the interaction
    // lightweight.
    if (tag.isEmpty) {
      return;
    }
    if (widget.tags.contains(tag)) {
      return;
    }
    widget.onChange?.call([...widget.tags, tag].toSet().toList());
  }

  // Tags display in the textfield, which is implemented as its Icon
  // more on this in the main builder
  Widget _buildSearchTagIconPart(
    BuildContext context,
    String tag, {
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 6.0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(999),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(tag),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: onTap,
              child: const Icon(Icons.close, size: 14),
            ),
          ],
        ),
      ),
    );
  }

  // Suggestion Item in the suggestion list
  Widget _buildSuggestionItem(
    BuildContext context,
    suggestion_models.Tags tag, {
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Row(
          children: [
            Icon(
              Icons.sell_outlined,
              size: 15,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tag.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(height: 1.1),
                  ),
                  if ((tag.translated_name ?? '').isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2.0),
                      child: Text(
                        tag.translated_name!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          height: 1.0,
                          color: Theme.of(
                            context,
                          ).textTheme.bodySmall?.color?.withValues(alpha: 0.72),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _suggestionDebounceTimer?.cancel();
    _textEditingController.dispose();
    super.dispose();
  }
}
