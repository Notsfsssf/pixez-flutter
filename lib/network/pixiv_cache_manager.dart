import 'package:dio/dio.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_cache_manager_dio/flutter_cache_manager_dio.dart';

/// Keep the existing disk cache, but normalize unknown transfer sizes to null.
/// The Dio adapter uses -1, which is invalid for Flutter's ImageChunkEvent.
class PixivCacheManager extends CacheManager {
  static PixivCacheManager? _instance;

  static PixivCacheManager get instance {
    final instance = _instance;
    if (instance == null) {
      throw StateError('PixivCacheManager.initialize() has not been called');
    }
    return instance;
  }

  /// Only the first call creates the manager; replace the Dio adapter to
  /// change network settings afterwards.
  static void initialize(Dio dio) {
    _instance ??= PixivCacheManager._(dio);
  }

  PixivCacheManager._(Dio dio)
    : super(Config(DioCacheManager.key, fileService: _ImageFileService(dio)));
}

class _ImageFileService extends DioHttpFileService {
  _ImageFileService(super.dio);

  @override
  Future<FileServiceResponse> get(
    String url, {
    Map<String, String>? headers,
  }) async {
    return _ImageResponse(await super.get(url, headers: headers));
  }
}

class _ImageResponse implements FileServiceResponse {
  _ImageResponse(this.response);
  final FileServiceResponse response;

  @override
  int? get contentLength {
    final length = response.contentLength;
    return length == null || length < 0 ? null : length;
  }

  @override
  String get fileExtension {
    try {
      return response.fileExtension;
    } catch (_) {
      // Cache an unlisted image MIME type without guessing its extension.
      // Flutter's decoder still validates the actual image bytes.
      return '';
    }
  }

  @override
  Stream<List<int>> get content => response.content;
  @override
  String? get eTag => response.eTag;
  @override
  int get statusCode => response.statusCode;
  @override
  DateTime get validTill => response.validTill;
}
