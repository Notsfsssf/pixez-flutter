enum IllustQuality { medium, large, original }

extension IllustQualityExtension on IllustQuality {
  static int value(IllustQuality quality) => switch (quality) {
    IllustQuality.medium => 0,
    IllustQuality.large => 1,
    IllustQuality.original => 2,
  };

  static IllustQuality fromValue(int value) {
    return switch (value) {
      0 => IllustQuality.medium,
      1 => IllustQuality.large,
      2 => IllustQuality.original,
      _ => IllustQuality.medium,
    };
  }
}

class IllustCacher {
  static Future<void> saveCacheIllustQuality(
    String key,
    IllustQuality quality,
    String url,
  ) async {
    MmapCache.save(key, 'original');
    MmapCache.save('${key}_quality_${quality.index}', url);
  }

  static String? findCacheIllustQuality(String key) {
    for (final quality in [
      IllustQuality.original,
      IllustQuality.large,
      IllustQuality.medium,
    ]) {
      final value = MmapCache.read('${key}_quality_${quality.index}');
      if (value != null) {
        return value;
      }
    }
    return null;
  }

  static String targetUrl(String sourceUrl, String key) {
    final value = findCacheIllustQuality(key);
    if (value != null) {
      return value;
    }
    return sourceUrl;
  }
}

class MmapCache {
  static Future<void> init() async {}

  static void save(String key, String value) {}

  static String? read(String key) {
    return null;
  }
}
