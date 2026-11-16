import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/illust.dart';

/// Mouse menus use the same download queue as the rest of the application.
Future<void> showArtworkContextMenu(
  BuildContext context,
  Offset position,
  Illusts artwork, {
  int? pageIndex,
}) async {
  final overlay = Overlay.of(context).context.findRenderObject()! as RenderBox;
  final local = overlay.globalToLocal(position);
  final labels = I18n.of(context);
  final action = await showMenu<String>(
    context: context,
    position: RelativeRect.fromRect(
      local & const Size(1, 1),
      Offset.zero & overlay.size,
    ),
    items: [
      PopupMenuItem(
        value: 'download',
        child: Row(
          children: [
            const Icon(Icons.download_outlined, size: 20),
            const SizedBox(width: 12),
            Text(labels.save),
          ],
        ),
      ),
      PopupMenuItem(
        value: 'copy',
        child: Row(
          children: [
            const Icon(Icons.link, size: 20),
            const SizedBox(width: 12),
            Text('${labels.copy} Pixiv URL'),
          ],
        ),
      ),
    ],
  );
  if (action == 'download') {
    await saveStore.saveImage(artwork, index: pageIndex);
  } else if (action == 'copy') {
    await Clipboard.setData(
      ClipboardData(text: 'https://www.pixiv.net/artworks/${artwork.id}'),
    );
  }
}
