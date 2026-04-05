extension HttpHeaderListExt on List<(String, String)> {
  Map<String, String> get asHeaderMap => {
    for (final entry in this) entry.$1: entry.$2,
  };

  Map<String, List<String>> get asHeaderMapList => () {
    final map = <String, List<String>>{};
    for (final entry in this) {
      map.putIfAbsent(entry.$1, () => []).add(entry.$2);
    }
    return map;
  }();
}
