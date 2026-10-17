import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pixez/page/hello/ranking/rank_store.dart';

void main() {
  // Rank pages look up tab titles by the index of a mode in
  // RankStore.intialModeList, so both lists must stay aligned.
  test('ranking modes line up with the mode_list titles', () {
    final arb = jsonDecode(File('lib/l10n/intl_en_US.arb').readAsStringSync())
        as Map<String, dynamic>;
    final titles = (arb['mode_list'] as String).split(' ');
    final modes = RankStore().intialModeList;

    expect(modes.length, titles.length);
    expect(titles[modes.indexOf('day_ai')], 'AI');
    expect(titles[modes.indexOf('day_r18')], 'XVIII');
    expect(titles[modes.indexOf('week_r18g')], 'XVIII_G');
  });
}
