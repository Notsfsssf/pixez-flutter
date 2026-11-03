import 'package:bot_toast/bot_toast.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pixez/utils/novel_save_target.dart';

/// 设置项：小说保存位置（点击选择目录，右侧按钮恢复默认）
class NovelSaveLocationTile extends StatefulWidget {
  const NovelSaveLocationTile({Key? key}) : super(key: key);

  @override
  State<NovelSaveLocationTile> createState() => _NovelSaveLocationTileState();
}

class _NovelSaveLocationTileState extends State<NovelSaveLocationTile> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.folder_outlined),
      title: const Text("小说保存位置"),
      subtitle: Text(
        NovelSaveTarget.display,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: NovelSaveTarget.isCustom
          ? IconButton(
              icon: const Icon(Icons.settings_backup_restore),
              tooltip: "恢复默认",
              onPressed: () async {
                await NovelSaveTarget.reset();
                if (!mounted) return;
                setState(() {});
                BotToast.showText(
                    text: "已恢复默认：${NovelSaveTarget.defaultDisplay}");
              },
            )
          : const Icon(Icons.arrow_right),
      onTap: () async {
        final ok = await NovelSaveTarget.pick();
        if (!mounted) return;
        if (ok) {
          setState(() {});
          BotToast.showText(text: "保存位置已设为：${NovelSaveTarget.display}");
        }
      },
    );
  }
}
