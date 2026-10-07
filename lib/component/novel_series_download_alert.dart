import 'package:flutter/material.dart';
import 'package:pixez/i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/models/novel_recom_response.dart';
import 'package:pixez/page/novel/series/novel_series_page.dart';

class NovelSeriesDownloadAlert extends StatefulHookConsumerWidget {
  const NovelSeriesDownloadAlert({
    super.key,
    required this.id,
  });

  final int id;

  @override
  ConsumerState<NovelSeriesDownloadAlert> createState() =>
      _NovelSeriesDownloadAlertState();
}

class _NovelSeriesDownloadAlertState
    extends ConsumerState<NovelSeriesDownloadAlert> {

  /// 当前选中的小说ID
  final Set<int> _selectedIds = <int>{};

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(novelSeriesProvider);
    final novels = data?.novels ?? const [];

    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              margin: const EdgeInsets.all(16),
              constraints: const BoxConstraints(
                maxWidth: 420,
                maxHeight: 650,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Theme.of(context).colorScheme.surface,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        data?.novelSeriesDetail.title ?? I18n.of(context).download_novel_series,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ),
                  const Divider(height: 1),

                  Expanded(
                    child: novels.isEmpty
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              vertical: 4,
                            ),
                            itemCount: novels.length,
                            itemBuilder: (context, index) {
                              return _buildNovelItem(
                                context,
                                novels[index],
                                index,
                              );
                            },
                          ),
                  ),

                  const Divider(height: 1),
                  _buildBottomBar(context, novels.length),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(
    BuildContext context,
    int total,
  ) {
    final data = ref.read(novelSeriesProvider);
    final novels = data?.novels ?? const [];

    final allSelected = novels.isNotEmpty &&
        novels.every((novel) => _selectedIds.contains(novel.id));

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 底部:全选/取消全选
        CheckboxListTile(
          value: allSelected,
          dense: true,
          title: Text(
            allSelected ? I18n.of(context).cancel_select_all : I18n.of(context).select_all,
          ),
          controlAffinity: ListTileControlAffinity.leading,
          onChanged: novels.isEmpty
              ? null
              : (_) {
                  setState(() {
                    if (allSelected) {
                      _selectedIds.clear();
                    } else {
                      _selectedIds
                        ..clear()
                        ..addAll(
                          novels.map((novel) => novel.id),
                        );
                    }
                  });
                },
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 8, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${I18n.of(context).selected} ${_selectedIds.length} / $total',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(I18n.of(context).cancel),
              ),
              TextButton(
                onPressed: _selectedIds.isEmpty
                    ? null
                    : () {
                        Navigator.of(context).pop(
                          NovelSeriesDownloadResult(
                            novelIds: _selectedIds.toList(),
                          ),
                        );
                      },
                child: Text(I18n.of(context).ok),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNovelItem(
    BuildContext context,
    Novel novel,
    int index,
  ) {
    final selected = _selectedIds.contains(novel.id);

    return InkWell(
      onTap: () {
        setState(() {
          if (selected) {
            _selectedIds.remove(novel.id);
          } else {
            _selectedIds.add(novel.id);
          }
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        child: Row(
          children: [
            Checkbox(
              value: selected,
              onChanged: (_) {
                setState(() {
                  if (selected) {
                    _selectedIds.remove(novel.id);
                  } else {
                    _selectedIds.add(novel.id);
                  }
                });
              },
            ),

            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: PixivImage(
                novel.imageUrls.medium,
                width: 48,
                height: 64,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(width: 8),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '#${index + 1} ${novel.title}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    novel.user.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .secondary,
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
}

class NovelSeriesDownloadResult {
  const NovelSeriesDownloadResult({
    required this.novelIds
  });

  final List<int> novelIds;
}