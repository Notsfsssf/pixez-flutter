/*
 * Copyright (C) 2020. by perol_notsf, All rights reserved
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program. If not, see <http://www.gnu.org/licenses/>.
 *
 */

import 'package:fluent_ui/fluent_ui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pixez/fluent/component/context_menu.dart';
import 'package:pixez/fluent/component/pixez_button.dart';
import 'package:pixez/fluent/component/pixiv_image.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/illust_persist.dart';
import 'package:pixez/fluent/page/picture/illust_lighting_page.dart';
import 'package:pixez/page/history/history_store.dart';
import 'package:pixez/page/picture/illust_store.dart';

class HistoryPage extends StatefulHookConsumerWidget {
  const HistoryPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  late TextEditingController _textEditingController;

  Widget buildBody(List<IllustPersist> data) => Builder(
        builder: (context) {
          final count =
              (MediaQuery.of(context).orientation == Orientation.portrait)
                  ? userSetting.crossCount
                  : userSetting.hCrossCount;

          final reIllust = data.reversed.toList();
          if (reIllust.isEmpty) return Container();

          return GridView.builder(
            itemCount: reIllust.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: count),
            itemBuilder: (context, index) => _HistoryItem(
              reIllust: reIllust,
              index: index,
            ),
          );
        },
      );

  @override
  void initState() {
    _textEditingController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(historyProvider.select((state) => state.data));
    return ScaffoldPage(
      header: PageHeader(
        title: Text(I18n.of(context).history),
        commandBar: TextBox(
          controller: _textEditingController,
          onChanged: (word) {
            if (word.trim().isNotEmpty) {
              ref.read(historyProvider.notifier).search(word.trim());
            } else {
              ref.read(historyProvider.notifier).fetch();
            }
          },
          placeholder: I18n.of(context).search_word_hint,
          prefix: IconButton(
            icon: Icon(FluentIcons.delete),
            onPressed: () async {
              final result = await showDialog(
                context: context,
                useRootNavigator: false,
                builder: (context) => ContentDialog(
                  title: Text('Clear All History?'),
                  actions: [
                    Button(
                      child: Text(I18n.of(context).cancel),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    FilledButton(
                      child: Text(I18n.of(context).ok),
                      onPressed: () => Navigator.of(context).pop('ok'),
                    ),
                  ],
                ),
              );
              if (result == 'ok') _cleanAll(context);
            },
          ),
          suffix: IconButton(
            icon: Icon(FluentIcons.clear),
            onPressed: () {
              _textEditingController.clear();
            },
          ),
        ),
      ),
      content: buildBody(data),
    );
  }

  Future<void> _cleanAll(BuildContext context) async {
    final result = await showDialog(
        context: context,
        builder: (context) {
          return ContentDialog(
            title: Text("${I18n.of(context).delete} ${I18n.of(context).all}?"),
            actions: <Widget>[
              HyperlinkButton(
                child: Text(I18n.of(context).cancel),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              HyperlinkButton(
                child: Text(I18n.of(context).ok),
                onPressed: () {
                  Navigator.of(context).pop("OK");
                },
              ),
            ],
          );
        });
    if (result == "OK") {
      ref.read(historyProvider.notifier).deleteAll();
    }
  }
}

class _HistoryItem extends HookConsumerWidget {
  final List<IllustPersist> reIllust;
  final int index;

  const _HistoryItem({required this.reIllust, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ContextMenu(
      child: PixEzButton(
        child: PixivImage(reIllust[index].pictureUrl),
        onPressed: () {
          Leader.push(
            context,
            IllustLightingPage(
                id: reIllust[index].illustId,
                store: IllustStore(reIllust[index].illustId, null)),
            icon: Icon(FluentIcons.picture),
            title: Text(
                I18n.of(context).illust_id + ': ${reIllust[index].illustId}'),
          );
        },
      ),
      items: [
        MenuFlyoutItem(
          text: Text(I18n.of(context).delete),
          onPressed: () async {
            await showDialog(
              context: context,
              builder: (context) {
                return ContentDialog(
                  title: Text("${I18n.of(context).delete}?"),
                  actions: <Widget>[
                    HyperlinkButton(
                      child: Text(I18n.of(context).cancel),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    HyperlinkButton(
                      child: Text(I18n.of(context).ok),
                      onPressed: () {
                        ref
                            .read(historyProvider.notifier)
                            .delete(reIllust[index].illustId);
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          },
        )
      ],
    );
  }
}
