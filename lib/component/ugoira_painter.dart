/*
 * Copyright (C) 2020. by perol_notsf, All rights reserved
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program. If not, see <http://www.gnu.org/licenses/>.
 *
 */

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/ugoira_metadata_response.dart';

class UgoiraWidget extends StatefulWidget {
  final List<FileSystemEntity> drawPools;
  final int delay;
  final Size size;
  final UgoiraMetadataResponse ugoiraMetadataResponse;

  const UgoiraWidget(
      {Key? key,
      required this.drawPools,
      required this.delay,
      required this.size,
      required this.ugoiraMetadataResponse})
      : super(key: key);

  @override
  _UgoiraWidgetState createState() => _UgoiraWidgetState();
}

class _UgoiraWidgetState extends State<UgoiraWidget> with RouteAware {
  static const int _allFrameLimit = 15;
  static const int _streamWindowSize = 4;

  int get _effectiveCacheSize {
    final total = widget.drawPools.length;
    return total <= _allFrameLimit ? total : _streamWindowSize;
  }

  final Map<int, ui.Image> _frameCache = <int, ui.Image>{};
  final Map<int, Future<ui.Image?>> _loadingFutures = <int, Future<ui.Image?>>{};

  int point = 0;
  ui.Image? image;
  bool _stopPainting = false;
  bool _disposed = false;
  int _playSessionId = 0;
  int _cacheEpoch = 0;
  Timer? _timer;
  final Stopwatch _stopwatch = Stopwatch();
  int _expectedFrameTime = 0;

  @override
  void initState() {
    super.initState();
    _startPlayback();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void didPopNext() {
    super.didPopNext();
    _startPlayback();
  }

  @override
  void didPushNext() {
    super.didPushNext();
    _pausePlayback();
    _trimCacheForBackground();
  }

  @override
  void didUpdateWidget(covariant UgoiraWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.drawPools != widget.drawPools) {
      _pausePlayback();
      _clearCache();
      point = 0;
      _startPlayback();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    routeObserver.unsubscribe(this);
    _pausePlayback();
    _clearCache();
    super.dispose();
  }

  int _getFrameDelay(int index) {
    final frames = widget.ugoiraMetadataResponse.ugoiraMetadata.frames;
    if (index >= 0 && index < frames.length) {
      final d = frames[index].delay;
      if (d > 0) return d;
    }
    return widget.delay > 0 ? widget.delay : 100;
  }

  ui.Image? _getFromCache(int index) {
    final img = _frameCache.remove(index);
    if (img != null) {
      _frameCache[index] = img;
      return img;
    }
    return null;
  }

  void _putInCache(int index, ui.Image img) {
    _frameCache.remove(index);
    _frameCache[index] = img;
    _evictIfNeeded();
  }

  void _evictIfNeeded() {
    final limit = _effectiveCacheSize;
    if (_frameCache.length <= limit) return;

    for (final idx in _frameCache.keys) {
      if (_frameCache[idx] == image) continue;
      final img = _frameCache.remove(idx);
      img?.dispose();
      break;
    }
  }

  Future<ui.Image?> _getOrLoadFrame(int index) async {
    final cached = _getFromCache(index);
    if (cached != null) {
      return cached;
    }
    if (_loadingFutures.containsKey(index)) {
      return _loadingFutures[index];
    }
    if (index < 0 || index >= widget.drawPools.length) return null;

    final entity = widget.drawPools[index];
    if (entity is! File) return null;

    final currentEpoch = _cacheEpoch;
    final future = _decodeFile(entity);
    _loadingFutures[index] = future;

    try {
      final decodedImage = await future;
      if (_disposed || currentEpoch != _cacheEpoch) {
        decodedImage?.dispose();
        return null;
      }
      if (decodedImage != null) {
        _putInCache(index, decodedImage);
      }
      return decodedImage;
    } catch (_) {
      return null;
    } finally {
      if (currentEpoch == _cacheEpoch) {
        _loadingFutures.remove(index);
      }
    }
  }

  Future<ui.Image?> _decodeFile(File file) async {
    try {
      final Uint8List data = await file.readAsBytes();
      return await decodeImageFromList(data);
    } catch (_) {
      return null;
    }
  }

  void _prefetch(int index) {
    if (_disposed || _stopPainting) return;
    if (index < 0 || index >= widget.drawPools.length) return;
    if (!_frameCache.containsKey(index) && !_loadingFutures.containsKey(index)) {
      _getOrLoadFrame(index);
    }
  }

  void _startPlayback() {
    _stopPainting = false;
    _timer?.cancel();
    _timer = null;
    _playSessionId++;
    final session = _playSessionId;
    _stopwatch.reset();
    _stopwatch.start();
    _expectedFrameTime = 0;
    _tick(session);
  }

  void _pausePlayback() {
    _stopPainting = true;
    _playSessionId++;
    _timer?.cancel();
    _timer = null;
    _stopwatch.stop();
  }

  void _clearCache() {
    _cacheEpoch++;
    _loadingFutures.clear();
    final Set<ui.Image> allImages = {..._frameCache.values};
    if (image != null) allImages.add(image!);
    for (final img in allImages) {
      img.dispose();
    }
    _frameCache.clear();
    image = null;
  }

  void _trimCacheForBackground() {
    final total = widget.drawPools.length;
    if (total == 0) return;

    // 保留恢复播放时最先需要的 3 帧缓冲，以及当前屏幕上展示的静止帧 image
    final keepIndices = <int>{
      point % total,
      (point + 1) % total,
      (point + 2) % total,
    };

    _frameCache.removeWhere((idx, img) {
      if (!keepIndices.contains(idx) && img != image) {
        img.dispose();
        return true;
      }
      return false;
    });
  }

  Future<void> _tick(int session) async {
    if (session != _playSessionId ||
        _stopPainting ||
        !mounted ||
        _disposed ||
        widget.drawPools.isEmpty) {
      return;
    }

    final currentIndex = point;
    final duration = _getFrameDelay(currentIndex);

    final nextImage = await _getOrLoadFrame(currentIndex);

    if (session != _playSessionId || _stopPainting || !mounted || _disposed) {
      return;
    }

    if (nextImage != null && mounted) {
      setState(() {
        image = nextImage;
      });
    }

    final total = widget.drawPools.length;
    if (total > 1) {
      _prefetch((currentIndex + 1) % total);
      _prefetch((currentIndex + 2) % total);
    }

    if (_expectedFrameTime == 0) {
      _expectedFrameTime = _stopwatch.elapsedMilliseconds + duration;
    } else {
      _expectedFrameTime += duration;
    }

    final now = _stopwatch.elapsedMilliseconds;
    int delayMs = _expectedFrameTime - now;

    if (delayMs < -100) {
      _expectedFrameTime = now + duration;
      delayMs = duration;
    } else if (delayMs < 0) {
      delayMs = 0;
    }

    point = (currentIndex + 1) % total;

    _timer = Timer(Duration(milliseconds: delayMs), () {
      if (session == _playSessionId && !_stopPainting && mounted && !_disposed) {
        _tick(session);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return image != null
        ? CustomPaint(
            painter: UgoiraPainter(image!),
            size: widget.size,
          )
        : Container();
  }
}

class UgoiraPainter extends CustomPainter {
  final ui.Image image;
  static final Paint _paint = Paint()..filterQuality = FilterQuality.low;

  UgoiraPainter(this.image);

  @override
  void paint(Canvas canvas, Size size) {
    final Rect srcRect =
        Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());
    final Rect dstRect =
        Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawImageRect(image, srcRect, dstRect, _paint);
  }

  @override
  bool shouldRepaint(UgoiraPainter oldDelegate) {
    return oldDelegate.image != image;
  }
}
