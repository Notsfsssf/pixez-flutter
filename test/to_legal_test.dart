import 'package:flutter_test/flutter_test.dart';
import 'package:pixez/exts.dart';

void main() {
  group('String.toLegal', () {
    test('removes characters that are invalid in FAT/NTFS file names', () {
      expect(r'a/b\c:d*e?f"g<h>i|j'.toLegal(), 'abcdefghij');
    });

    test('removes double quotes from titles (#1280)', () {
      expect(
        '"公务员登门不慎遗失工牌后意外被调教为优质家畜..."_p0.png'.toLegal(),
        '公务员登门不慎遗失工牌后意外被调教为优质家畜..._p0.png',
      );
    });

    test('removes control characters', () {
      expect('a\u0000b\tc\nd\u001fe\u007ff'.toLegal(), 'abcdef');
    });

    test('keeps other characters unchanged', () {
      const name = '初音ミク 「テスト」 (1) [x] #tag ★_p0.jpg';
      expect(name.toLegal(), name);
    });
  });
}
