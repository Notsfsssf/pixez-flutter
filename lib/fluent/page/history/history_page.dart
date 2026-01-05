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

import 'dart:math';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/fluent/component/context_menu.dart';
import 'package:pixez/fluent/component/pixez_button.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/models/illust_persist.dart';
import 'package:pixez/page/history/history_store.dart';
import 'package:pixez/page/picture/illust_lighting_page.dart';
import 'package:pixez/page/picture/illust_store.dart';

class HistoryPage extends HookConsumerWidget {
  const HistoryPage({super.key});

  Widget buildAppBarUI(context) => Container(
    child: Padding(
      child: Text(
        I18n.of(context).history,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30.0),
      ),
      padding: EdgeInsets.only(left: 20.0, top: 30.0, bottom: 30.0),
    ),
  );

  Widget buildBody(List<IllustPersist> data, WidgetRef ref) {
    final reIllust = data.reversed.toList();
    if (reIllust.isEmpty) {
      return Center(child: Container());
    }
    return LayoutBuilder(
      builder: (context, snapshot) {
        final rowCount = max(2, (snapshot.maxWidth / 200).floor());
        return GridView.builder(
          itemCount: reIllust.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: rowCount,
          ),
          itemBuilder: (context, index) =>
              _HistoryItem(reIllust: reIllust, index: index),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataFuture = ref.watch(historyProvider);
    final _textEditingController = useTextEditingController();
    useEffect(() {
      Future.delayed(Duration.zero, () async {
        await ref.read(historyProvider.notifier).fetch();
      });
      return null;
    }, []);
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
            onPressed: () async => await _cleanAll(context, ref),
          ),
          suffix: IconButton(
            icon: Icon(FluentIcons.clear),
            onPressed: () => _textEditingController.clear(),
          ),
        ),
      ),
      content: buildBody(dataFuture.data, ref),
    );
  }

  Future<void> _cleanAll(BuildContext context, WidgetRef ref) async {
    final result = await showDialog(
      context: context,
      builder: (context) {
        return ContentDialog(
          title: Text("${I18n.of(context).delete} ${I18n.of(context).all}?"),
          actions: <Widget>[
            Button(
              child: Text(I18n.of(context).cancel),
              onPressed: () => Navigator.of(context).pop(),
            ),
            FilledButton(
              child: Text(I18n.of(context).ok),
              onPressed: () => Navigator.of(context).pop("OK"),
            ),
          ],
        );
      },
    );
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
        onPressed: () => _navigateTo(context),
      ),
      items: [
        MenuFlyoutItem(
          text: Text("Open"), // TODO: I18n
          leading: Icon(FluentIcons.open_in_new_window),
          onPressed: () => _navigateTo(context),
        ),
        MenuFlyoutItem(
          text: Text(I18n.of(context).delete),
          leading: Icon(FluentIcons.delete),
          onPressed: () => _delete(context, ref),
        ),
      ],
    );
  }

  void _navigateTo(BuildContext context) {
    Leader.push(
      context,
      IllustLightingPage(
        id: reIllust[index].illustId,
        store: IllustStore(reIllust[index].illustId, null),
      ),
      icon: Icon(FluentIcons.picture),
      title: Text(I18n.of(context).illust_id + ': ${reIllust[index].illustId}'),
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final result = await showDialog(
      context: context,
      builder: (context) {
        return ContentDialog(
          title: Text("${I18n.of(context).delete}?"),
          actions: <Widget>[
            Button(
              child: Text(I18n.of(context).cancel),
              onPressed: () => Navigator.of(context).pop(),
            ),
            FilledButton(
              child: Text(I18n.of(context).ok),
              onPressed: () => Navigator.of(context).pop("OK"),
            ),
          ],
        );
      },
    );
    if (result == "OK") {
      ref.read(historyProvider.notifier).delete(reIllust[index].illustId);
    }
  }
}
