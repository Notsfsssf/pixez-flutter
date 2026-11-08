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
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:pixez/models/ugoira_metadata_response.dart';

class UgoiraWidget extends StatefulWidget {
  final List<FileSystemEntity> drawPools;
  final int delay;
  final Size size;
  final UgoiraMetadataResponse ugoiraMetadataResponse;

  const UgoiraWidget({
    Key? key,
    required this.drawPools,
    required this.delay,
    required this.size,
    required this.ugoiraMetadataResponse,
  }) : super(key: key);

  @override
  _UgoiraWidgetState createState() => _UgoiraWidgetState();
}

class _UgoiraWidgetState extends State<UgoiraWidget>
    with SingleTickerProviderStateMixin {
  /// Decoded RGBA bytes kept resident. Short loops stay fully decoded; longer
  /// ones keep a forward window and dispose frames that fall behind it.
  static const int _budgetBytes = 48 * 1024 * 1024;
  static const int _minWindow = 4;
  static const int _offstageWindow = 3;

  /// A muted ticker does not fire, but its clock keeps running. The first
  /// callback after a covered route or a backgrounded app is one long gap.
  static const Duration _maxTickGap = Duration(milliseconds: 100);

  late final Ticker _ticker;

  List<File?> _files = const [];
  List<int> _delays = const [];
  List<ui.Image?> _images = const [];
  List<bool> _failed = const [];
  final Set<int> _decoding = <int>{};
  final List<ui.Image> _pendingDispose = <ui.Image>[];

  ui.Image? _shown;
  int _count = 0;
  int _index = 0;
  int _intoFrameUs = 0;
  int _limit = 0;
  int _sampleBytes = 0;
  int _targetWidth = 1;
  int _appliedTargetWidth = -1;
  int _generation = 0;
  Duration? _lastElapsed;
  bool _offstage = false;
  bool _pumping = false;
  bool _pumpAgain = false;
  bool _retireScheduled = false;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final offstage = !TickerMode.valuesOf(context).enabled;
    final enteredStage = _offstage && !offstage;
    _offstage = offstage;
    final restarted = _syncTarget();
    if (_offstage) {
      _applyWindow();
      if (!_windowReady()) _schedulePump();
    } else if (enteredStage && !restarted) {
      _schedulePump();
    }
  }

  @override
  void didUpdateWidget(covariant UgoiraWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.drawPools != widget.drawPools ||
        oldWidget.ugoiraMetadataResponse != widget.ugoiraMetadataResponse ||
        oldWidget.delay != widget.delay ||
        oldWidget.size != widget.size) {
      _syncTarget(force: true);
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _generation++;
    _pumpAgain = false;
    _stopTicker();
    _ticker.dispose();
    _disposeAllNow();
    super.dispose();
  }

  bool _syncTarget({bool force = false}) {
    final target = _decodeTargetWidth();
    if (!force && target == _appliedTargetWidth && _generation != 0) {
      return false;
    }
    _appliedTargetWidth = target;
    _targetWidth = target;
    _restart();
    return true;
  }

  int _decodeTargetWidth() {
    final width = widget.size.width;
    if (!width.isFinite || width <= 0) return 1;
    final target = (width * View.of(context).devicePixelRatio).round();
    if (target < 1) return 1;
    if (target > 4096) return 4096;
    return target;
  }

  void _restart() {
    _generation++;
    _decoding.clear();
    _stopTicker();
    _retireCachedImages();
    _captureSources();
    _index = 0;
    _intoFrameUs = 0;
    _lastElapsed = null;
    _sampleBytes = 0;
    _limit = math.min(_count, _minWindow);
    if (_count == 0) {
      _pumpAgain = false;
      final shown = _shown;
      if (shown != null) {
        _shown = null;
        _retireImage(shown);
      }
      return;
    }
    _schedulePump();
  }

  void _captureSources() {
    final pools = widget.drawPools;
    _count = pools.length;
    _files = List<File?>.generate(pools.length, (index) {
      final entity = pools[index];
      return entity is File ? entity : null;
    });
    _delays = List<int>.generate(pools.length, _delayAt);
    _images = List<ui.Image?>.filled(pools.length, null);
    _failed = List<bool>.filled(pools.length, false);
  }

  int _delayAt(int index) {
    final frames = widget.ugoiraMetadataResponse.ugoiraMetadata.frames;
    if (index >= 0 && index < frames.length && frames[index].delay > 0) {
      return frames[index].delay;
    }
    if (widget.delay > 0) return widget.delay;
    return 100;
  }

  int _limitFor(int count) {
    if (count <= 0) return 0;
    if (_sampleBytes <= 0) return math.min(count, _minWindow);
    final affordable = _budgetBytes ~/ _sampleBytes;
    final lower = math.min(_minWindow, count);
    if (affordable < lower) return lower;
    if (affordable > count) return count;
    return affordable;
  }

  int _span() {
    if (_count == 0) return 0;
    if (_offstage) return math.min(_offstageWindow, _count);
    if (_limit < 1) return 1;
    return _limit > _count ? _count : _limit;
  }

  Set<int> _wantedIndices() {
    final result = <int>{};
    final span = _span();
    for (var i = 0; i < span; i++) {
      result.add((_index + i) % _count);
    }
    return result;
  }

  List<int> _orderedFromCurrent(Set<int> indices) {
    final ordered = indices.toList();
    ordered.sort((a, b) {
      final da = (a - _index) % _count;
      final db = (b - _index) % _count;
      return da.compareTo(db);
    });
    return ordered;
  }

  bool _alive(int generation) =>
      mounted && !_disposed && generation == _generation;

  void _schedulePump() {
    if (_disposed || _count == 0) return;
    _pumpAgain = true;
    if (_pumping) return;
    _pumping = true;
    scheduleMicrotask(() async {
      await _runPump();
    });
  }

  Future<void> _runPump() async {
    final generation = _generation;
    try {
      while (_pumpAgain && _alive(generation)) {
        _pumpAgain = false;
        await _fillWindow(generation);
      }
    } finally {
      _pumping = false;
    }
    if (_pumpAgain && !_disposed && mounted) {
      _schedulePump();
    }
  }

  Future<void> _fillWindow(int generation) async {
    if (!_alive(generation) || _count == 0) return;
    final wanted = _wantedIndices();
    _evictExcept(wanted);
    for (final index in _orderedFromCurrent(wanted)) {
      if (!_alive(generation)) return;
      await _decodeInto(index, generation);
    }
    if (_alive(generation) && !_hasPendingOrReady()) _stopTicker();
  }

  bool _hasPendingOrReady() {
    for (var i = 0; i < _count; i++) {
      if (_images[i] != null || !_failed[i]) return true;
    }
    return false;
  }

  Future<void> _decodeInto(int index, int generation) async {
    if (_images[index] != null || _failed[index] || _decoding.contains(index)) {
      return;
    }
    final file = _files[index];
    if (file == null) {
      _failed[index] = true;
      _showCurrentIfReady();
      return;
    }
    _decoding.add(index);
    ui.Image? image;
    var stored = false;
    try {
      image = await _decodeFile(file);
      if (!_alive(generation) || !_wantedIndices().contains(index)) return;
      if (image == null) {
        _failed[index] = true;
        _showCurrentIfReady();
        return;
      }
      final existing = _images[index];
      _images[index] = image;
      stored = true;
      if (existing != null) _retireImage(existing);
      if (_sampleBytes == 0) {
        _sampleBytes = image.width * image.height * 4;
        final limit = _limitFor(_count);
        if (limit != _limit) {
          _limit = limit;
          _pumpAgain = true;
        }
      }
      _showCurrentIfReady();
    } finally {
      if (generation == _generation) _decoding.remove(index);
      if (!stored) image?.dispose();
    }
  }

  Future<ui.Image?> _decodeFile(File file) async {
    try {
      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) return null;
      final codec = await ui.instantiateImageCodec(
        bytes,
        targetWidth: _targetWidth,
        allowUpscaling: false,
      );
      try {
        final frame = await codec.getNextFrame();
        return frame.image;
      } finally {
        codec.dispose();
      }
    } catch (_) {
      return null;
    }
  }

  void _showCurrentIfReady() {
    if (_count == 0) return;
    final start = _index;
    for (var hop = 0; hop < _count; hop++) {
      final frame = _images[_index];
      if (frame != null) {
        _setShown(frame);
        _ensureTicking();
        if (_index != start) _schedulePump();
        return;
      }
      if (!_failed[_index]) return;
      _index = (_index + 1) % _count;
      _intoFrameUs = 0;
    }
    _stopTicker();
  }

  void _ensureTicking() {
    if (_disposed || _count <= 1 || _ticker.isActive) return;
    _lastElapsed = null;
    _ticker.start();
  }

  void _stopTicker() {
    _lastElapsed = null;
    if (_ticker.isActive) _ticker.stop();
  }

  void _onTick(Duration elapsed) {
    if (_disposed || _count <= 1) return;
    final last = _lastElapsed;
    _lastElapsed = elapsed;
    if (last == null) return;
    final delta = elapsed - last;
    if (delta <= Duration.zero || delta > _maxTickGap) return;
    _advance(delta.inMicroseconds);
  }

  void _advance(int deltaUs) {
    if (_count <= 1) return;
    _intoFrameUs += deltaUs;
    for (var hop = 0; hop <= _count; hop++) {
      if (_failed[_index] && _images[_index] == null) {
        _index = (_index + 1) % _count;
        _intoFrameUs = 0;
        continue;
      }
      final frame = _images[_index];
      if (frame == null) {
        _schedulePump();
        return;
      }
      if (!identical(_shown, frame)) _setShown(frame);
      final delayUs = _delays[_index] * 1000;
      if (_intoFrameUs < delayUs) return;
      final next = (_index + 1) % _count;
      if (_images[next] == null && !_failed[next]) {
        _intoFrameUs = delayUs;
        _schedulePump();
        return;
      }
      _intoFrameUs -= delayUs;
      _index = next;
      final nextFrame = _images[_index];
      if (nextFrame != null) _setShown(nextFrame);
      if (_limit < _count || _offstage) {
        _applyWindow();
        if (!_windowReady()) _schedulePump();
      }
    }
  }

  bool _windowReady() {
    for (final index in _wantedIndices()) {
      if (_images[index] == null && !_failed[index]) return false;
    }
    return true;
  }

  void _applyWindow() {
    if (_count == 0) return;
    _evictExcept(_wantedIndices());
  }

  void _evictExcept(Set<int> keep) {
    for (var i = 0; i < _images.length; i++) {
      if (keep.contains(i)) continue;
      final image = _images[i];
      if (image == null) continue;
      _images[i] = null;
      _retireImage(image);
    }
  }

  void _setShown(ui.Image image) {
    if (identical(_shown, image)) return;
    final previous = _shown;
    _shown = image;
    if (previous != null && !_images.contains(previous)) {
      _retireImage(previous);
    }
    if (mounted) setState(() {});
  }

  void _retireImage(ui.Image image) {
    if (identical(image, _shown)) return;
    _pendingDispose.add(image);
    _scheduleRetire();
  }

  void _retireCachedImages() {
    for (final image in _images) {
      if (image != null && !identical(image, _shown)) {
        _pendingDispose.add(image);
      }
    }
    _images = const [];
    _scheduleRetire();
  }

  void _scheduleRetire() {
    if (_retireScheduled || _pendingDispose.isEmpty || _disposed) return;
    _retireScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => _flushRetired());
  }

  void _flushRetired() {
    _retireScheduled = false;
    if (_disposed) return;
    final batch = List<ui.Image>.of(_pendingDispose);
    _pendingDispose.clear();
    final live = <ui.Image>{
      if (_shown != null) _shown!,
      for (final image in _images)
        if (image != null) image,
    };
    final disposed = <ui.Image>{};
    for (final image in batch) {
      if (!disposed.add(image) || live.contains(image)) continue;
      image.dispose();
    }
  }

  void _disposeAllNow() {
    final images = <ui.Image>{..._pendingDispose};
    _pendingDispose.clear();
    for (final image in _images) {
      if (image != null) images.add(image);
    }
    if (_shown != null) images.add(_shown!);
    _images = const [];
    _shown = null;
    for (final image in images) {
      image.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final shown = _shown;
    return SizedBox.fromSize(
      size: widget.size,
      child: shown == null
          ? null
          : RawImage(
              image: shown,
              width: widget.size.width,
              height: widget.size.height,
              fit: BoxFit.fill,
              filterQuality: FilterQuality.medium,
            ),
    );
  }
}
