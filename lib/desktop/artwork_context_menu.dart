import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/illust.dart';
import 'package:pixez/page/picture/illust_store.dart';

/// Mouse menus use the same download queue as the rest of the application.
/// Pass [store] to offer the bookmark actions touch users reach from the star.
Future<void> showArtworkContextMenu(
  BuildContext context,
  Offset position,
  Illusts artwork, {
  int? pageIndex,
  IllustStore? store,
}) async {
  final bookmarked = store?.illusts?.isBookmarked ?? false;
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
      if (store != null) ...[
        PopupMenuItem(
          value: 'bookmark',
          child: Row(
            children: [
              Icon(
                bookmarked ? Icons.favorite : Icons.favorite_border,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(bookmarked ? labels.bookmarked : labels.bookmark),
            ],
          ),
        ),
        if (!bookmarked)
          PopupMenuItem(
            value: 'bookmark_private',
            child: Row(
              children: [
                const Icon(Icons.lock_outline, size: 20),
                const SizedBox(width: 12),
                Text('${labels.private} ${labels.bookmark}'),
              ],
            ),
          ),
        const PopupMenuDivider(),
      ],
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
  if (action == 'bookmark') {
    // Toggles: removes the bookmark when the artwork is already bookmarked.
    await store!.star(
      restrict: userSetting.defaultPrivateLike ? 'private' : 'public',
    );
  } else if (action == 'bookmark_private') {
    await store!.star(restrict: 'private');
  } else if (action == 'download') {
    await saveStore.saveImage(artwork, index: pageIndex);
  } else if (action == 'copy') {
    await Clipboard.setData(
      ClipboardData(text: 'https://www.pixiv.net/artworks/${artwork.id}'),
    );
  }
}
