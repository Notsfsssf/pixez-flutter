import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/glance_illust_persist.dart';
import 'package:pixez/page/history/history_store.dart';

class DataExportPage extends HookConsumerWidget {
  const DataExportPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final errorColor = Colors.red;
    return ScaffoldPage.scrollable(
      header: PageHeader(
        title: Text(I18n.of(context).app_data),
      ),
      children: [
        _buildAppDataListTile(
          context,
          I18n.of(context).search_history,
          FluentIcons.search,
          () async {
            try {
              await tagHistoryStore.exportData(context);
            } catch (e) {
              print(e);
              BotToast.showText(text: e.toString());
            }
          },
          () async {
            try {
              await tagHistoryStore.importData();
            } catch (e) {
              print(e);
              BotToast.showText(text: e.toString());
            }
          },
        ),
        _buildAppDataListTile(
          context,
          I18n.of(context).bookmark_tag,
          FluentIcons.favorite_star,
          () async {
            try {
              await bookTagStore.exportData(context);
            } catch (e) {
              print(e);
              BotToast.showText(text: e.toString());
            }
          },
          () async {
            try {
              await bookTagStore.importData();
            } catch (e) {
              print(e);
              BotToast.showText(text: e.toString());
            }
          },
        ),
        _buildAppDataListTile(
          context,
          I18n.of(context).illust_history,
          FluentIcons.photo_collection,
          () async {
            try {
              await ref.read(historyProvider.notifier).fetch();
              await ref.read(historyProvider.notifier).exportData(context);
            } catch (e) {
              print(e);
              BotToast.showText(text: e.toString());
            }
          },
          () async {
            try {
              await ref.read(historyProvider.notifier).fetch();
              await ref.read(historyProvider.notifier).importData();
            } catch (e) {
              print(e);
              BotToast.showText(text: e.toString());
            }
          },
        ),
        _buildAppDataListTile(
          context,
          I18n.of(context).novel_history,
          FluentIcons.book_answers,
          () async {
            try {
              await novelHistoryStore.fetch();
              await novelHistoryStore.exportData(context);
            } catch (e) {
              print(e);
              BotToast.showText(text: e.toString());
            }
          },
          () async {
            try {
              await novelHistoryStore.fetch();
              await novelHistoryStore.importData();
            } catch (e) {
              print(e);
              BotToast.showText(text: e.toString());
            }
          },
        ),
        _buildAppDataListTile(
          context,
          I18n.of(context).mute_data,
          FluentIcons.blocked,
          () async {
            try {
              await muteStore.export(context);
            } catch (e) {
              print(e);
              BotToast.showText(text: e.toString());
            }
          },
          () async {
            try {
              await muteStore.importFile();
            } catch (e) {
              print(e);
              BotToast.showText(text: e.toString());
            }
          },
        ),
        const Divider(),
        ListTile(
          leading: Icon(
            FluentIcons.clear,
            color: errorColor,
          ),
          title: Text(
            I18n.of(context).clear_all_cache,
            style: TextStyle(color: errorColor),
          ),
          onPressed: () async {
            try {
              await _showClearCacheDialog(context);
            } catch (e) {}
          },
        ),
      ],
    );
  }

  Future _showClearCacheDialog(BuildContext context) async {
    final result = await showDialog(
      builder: (BuildContext context) {
        return ContentDialog(
          title: Text(I18n.of(context).clear_all_cache),
          actions: <Widget>[
            Button(
              child: Text(I18n.of(context).cancel),
              onPressed: () {
                Navigator.of(context).pop("CANCEL");
              },
            ),
            FilledButton(
              child: Text(I18n.of(context).ok),
              onPressed: () {
                Navigator.of(context).pop("OK");
              },
            ),
          ],
        );
      },
      context: context,
    );
    switch (result) {
      case "OK":
        {
          try {
            Directory tempDir = await getTemporaryDirectory();
            tempDir.deleteSync(recursive: true);
            cleanGlanceData();
          } catch (e) {}
        }
        break;
    }
  }

  void cleanGlanceData() async {
    GlanceIllustPersistProvider glanceIllustPersistProvider =
        GlanceIllustPersistProvider();
    await glanceIllustPersistProvider.open();
    await glanceIllustPersistProvider.deleteAll();
    await glanceIllustPersistProvider.close();
  }

  Widget _buildAppDataListTile(
    BuildContext context,
    String title,
    IconData icon,
    Function() onExport,
    Function() onImport,
  ) {
    return ListTile(
      title: Text(title),
      leading: Icon(icon),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          HyperlinkButton(
            child: Text(I18n.of(context).import_title),
            onPressed: onImport,
          ),
          HyperlinkButton(
            child: Text(I18n.of(context).export),
            onPressed: onExport,
          ),
        ],
      ),
    );
  }
}
