extension StringExt on String {
  int? toInt() {
    return int.tryParse(this);
  }
}
