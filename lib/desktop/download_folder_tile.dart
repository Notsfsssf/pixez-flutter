import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pixez/document_plugin.dart';
import 'package:pixez/i18n.dart';

class DownloadFolderTile extends StatefulWidget {
  const DownloadFolderTile({super.key});

  @override
  State<DownloadFolderTile> createState() => _DownloadFolderTileState();
}

class _DownloadFolderTileState extends State<DownloadFolderTile> {
  String? _path;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final path = await DocumentPlugin.getPath();
      if (mounted) setState(() => _path = path);
    } on PlatformException catch (_) {
      // The picker remains available if a previous bookmark cannot be resolved.
    }
  }

  Future<void> _choose() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final selection = await DocumentPlugin.choiceFolder();
      if (selection != null) await _load();
    } on PlatformException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error.message ?? I18n.of(context).loading_failed_retry_message,
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: const ValueKey('download-folder'),
      leading: const Icon(Icons.folder_outlined),
      title: Text(I18n.of(context).save_path),
      subtitle: Tooltip(
        message: _path ?? '',
        child: Text(_path ?? '…', maxLines: 2, overflow: TextOverflow.ellipsis),
      ),
      onTap: _busy ? null : _choose,
      trailing: _busy
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.folder_open),
    );
  }
}
