import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pixez/page/hello/ranking/rank_store.dart';

void main() {
  test('R-18 male/female ranking modes have matching titles (#1333)', () {
    final arb = jsonDecode(File('lib/l10n/intl_en_US.arb').readAsStringSync())
        as Map<String, dynamic>;
    final titles = (arb['mode_list'] as String).split(' ');
    final modes = RankStore().intialModeList;

    expect(modes.length, titles.length);
    expect(titles[modes.indexOf('day_r18')], 'XVIII');
    expect(titles[modes.indexOf('day_male_r18')], 'XVIII_For_male');
    expect(titles[modes.indexOf('day_female_r18')], 'XVIII_For_female');
    expect(titles[modes.indexOf('week_r18g')], 'XVIII_G');
  });
}
