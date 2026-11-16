import 'package:characters/characters.dart';

import 'emoji_names.dart';

enum FilenameEmojiMode { underscore, remove, english }

// Match emoji before filename punctuation is removed, so keycaps such as *️⃣
// are replaced as a whole. Include flags, skin tones, ZWJ and tag sequences.
final _filenameEmoji = RegExp(
  r'(?:[#*0-9]\uFE0F?\u20E3|'
  r'[\p{Extended_Pictographic}\p{Regional_Indicator}\p{Emoji_Modifier}]'
  r'[\p{Extended_Pictographic}\p{Regional_Indicator}\p{Emoji_Modifier}'
  r'\u200D\uFE0E\uFE0F\u{E0020}-\u{E007F}]*)+',
  unicode: true,
);

final _emojiPresentation = RegExp(r'[\uFE0E\uFE0F]');
final _filenameSeparators = RegExp(r'[/\\]');

/// Clean emoji before creating files or checking for them.
/// Spaces, non-emoji Unicode, extensions and directory separators are preserved.
String replaceFilenameEmoji(
  String name, {
  FilenameEmojiMode mode = FilenameEmojiMode.underscore,
  bool capitalize = false,
}) {
  if (mode == FilenameEmojiMode.underscore) {
    return name.replaceAll(_filenameEmoji, '_');
  }
  if (mode == FilenameEmojiMode.remove) {
    return name.splitMapJoin(
      _filenameSeparators,
      onMatch: (match) => match[0]!,
      onNonMatch: (part) {
        final cleaned = part.replaceAll(_filenameEmoji, '');
        if (cleaned == part) return part;
        // An emoji-only directory must not disappear into a path separator.
        if (cleaned.isEmpty || cleaned == '.' || cleaned == '..') return '_';
        // Keep a basename when only the file extension remains.
        if (cleaned.lastIndexOf('.') == 0) return '_$cleaned';
        return cleaned;
      },
    );
  }
  return name.replaceAllMapped(_filenameEmoji, (match) {
    return match[0]!.characters
        .map((emoji) {
          final key = emoji.replaceAll(_emojiPresentation, '');
          final english = filenameEmojiEnglishNames[key];
          if (english == null || english.isEmpty) return '_';
          return capitalize
              ? '${english[0].toUpperCase()}${english.substring(1)}'
              : english;
        })
        .join('_');
  });
}
