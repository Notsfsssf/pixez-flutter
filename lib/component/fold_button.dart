import 'package:flutter/material.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/utils/haptic_util.dart';

/// Toggles folding of a multi-page work's remaining pages. Shared by the
/// single-column and pad (split) detail pages.
class FoldButton extends StatelessWidget {
  final bool folded;
  final int remainingPages;
  final VoidCallback onToggle;

  const FoldButton({
    super.key,
    required this.folded,
    required this.remainingPages,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticUtil.selectionClick();
        onToggle();
      },
      child: Container(
        height: 48,
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(folded ? Icons.expand_more : Icons.expand_less, size: 20),
            const SizedBox(width: 4),
            Text(
              folded
                  ? I18n.of(context).expand_remaining_pages(remainingPages)
                  : I18n.of(context).collapse_pages,
            ),
          ],
        ),
      ),
    );
  }
}
