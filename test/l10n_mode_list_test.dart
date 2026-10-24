import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

// mode_list and novel_mode_list are split by spaces and indexed by ranking
// mode, so every locale must have exactly as many entries as the template.
const _spaceSeparatedKeys = ['mode_list', 'novel_mode_list'];

Map<String, dynamic> _readArb(File file) =>
    jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;

void main() {
  final template = _readArb(File('lib/l10n/intl_en_US.arb'));
  final arbFiles = Directory('lib/l10n')
      .listSync()
      .whereType<File>()
      .where((file) => file.path.endsWith('.arb'))
      .toList();

  for (final key in _spaceSeparatedKeys) {
    final expected = (template[key] as String).split(' ').length;
    for (final file in arbFiles) {
      test('$key in ${file.uri.pathSegments.last} has $expected entries', () {
        final value = _readArb(file)[key] as String?;
        expect(value?.split(' ').length, expected);
      });
    }
  }
}
