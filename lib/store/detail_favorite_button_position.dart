enum DetailFavoriteButtonPosition {
  right(0),
  left(1),
  custom(2);

  const DetailFavoriteButtonPosition(this.value);

  final int value;

  static DetailFavoriteButtonPosition fromValue(int? storedValue) {
    if (storedValue != null) {
      for (final value in values) {
        if (value.value == storedValue) return value;
      }
    }
    return right;
  }
}
