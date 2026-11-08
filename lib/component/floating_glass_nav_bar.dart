// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

import 'dart:math' as math;
import 'dart:ui';

import 'package:pixez/utils/haptic_util.dart';
import 'package:material_ui/material_ui.dart';

/// 一个标签栏上的目标页。
class GlassNavDestination {
  const GlassNavDestination({
    required this.icon,
    required this.label,
    this.activeIcon,
  });

  final IconData icon;
  final String label;
  final IconData? activeIcon;
}

/// 悬浮磨砂标签栏：半透明胶囊底 + 灰色选中块 + 拖动切换。
///
/// 选中块用中性灰，在浅色和深色主题下都能压住底图：
///
/// * 整条栏是一条悬浮在内容之上的磨砂玻璃药丸，浅色/深色各有一套透明度；
/// * 选中的标签被一块半透明的灰色圆角块包住，四边内缩一致，
///   里面的图标与文字加深、加粗，未选中的保持灰色；
/// * 点击或按住拖拽都能切换，选中块在移动过程中会被横向拉长，
///   落位时按弹性曲线回弹，两侧文字做颜色交叉渐变。
class FloatingGlassNavBar extends StatefulWidget {
  const FloatingGlassNavBar({
    super.key,
    required this.currentIndex,
    required this.destinations,
    required this.onDestinationSelected,
    this.height = 56.0,
    this.horizontalMargin = 20.0,
    this.bottomMargin = 10.0,
    this.blurSigma = 24.0,
  });

  final int currentIndex;
  final List<GlassNavDestination> destinations;
  final ValueChanged<int> onDestinationSelected;

  final double height;
  final double horizontalMargin;
  final double bottomMargin;
  final double blurSigma;

  /// 栏离屏幕底边的距离：系统手势区只吃掉六成，剩下的交给 [bottomMargin]，
  /// 这样栏会贴着底部悬浮，而不是被安全区顶得很高。
  static double _bottomGap(MediaQueryData media, double bottomMargin) {
    return math.max(0.0, media.padding.bottom * 0.6) + bottomMargin;
  }

  /// 栏在屏幕上实际占用的高度（含底部安全区与下边距）。
  static double occupiedHeight(
    BuildContext context, {
    double height = 56.0,
    double bottomMargin = 10.0,
  }) {
    return _bottomGap(MediaQuery.of(context), bottomMargin) + height;
  }

  @override
  State<FloatingGlassNavBar> createState() => _FloatingGlassNavBarState();
}

class _FloatingGlassNavBarState extends State<FloatingGlassNavBar>
    with SingleTickerProviderStateMixin {
  /// 选中块四周相对栏的内缩，四个方向一致。
  static const double _inset = 4.0;

  /// 切换一次的时长，带一点弹性，落位后不再抖动。
  static const Duration _switchDuration = Duration(milliseconds: 600);

  /// 移动过程中选中块最多被拉长的比例。
  static const double _stretchMax = 0.32;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _switchDuration,
    value: 1.0,
  );

  late Tween<double> _tween = Tween<double>(
    begin: widget.currentIndex.toDouble(),
    end: widget.currentIndex.toDouble(),
  );

  final Curve _springCurve = const _SpringSettleCurve();

  bool _dragging = false;

  /// 拖动过程中选中块所处的小数位置。
  double _dragIndex = 0.0;

  /// 起拖时选中块所在的位置，整段拖拽都是它加上手指位移，绝不跳到手指下。
  double _dragStartIndex = 0.0;

  /// 起拖之后手指累计的横向位移（逻辑像素）。
  double _dragDx = 0.0;

  /// 拖动时每帧跨过的格数（平滑过），用来算拉伸量。
  double _dragDeltaIndex = 0.0;

  /// 起手落在别的格子上时先当成一次点击：手指没怎么动就切过去，
  /// 动了就作废，避免“点一下却把选中块甩到远处”。
  int _pendingTapIndex = -1;

  /// 候选点击之后手指移动的距离。
  double _pendingTapDx = 0.0;

  /// 当前被按住的目标，用于按下时的纵向压缩。
  int _pressedIndex = -1;

  double _cellWidth = 0.0;

  int get _count => widget.destinations.length;

  double get _maxIndex => math.max(0, _count - 1).toDouble();

  /// 选中块的小数位置。
  double get _position {
    final value = _dragging
        ? _dragIndex
        : _tween.transform(_springCurve.transform(_controller.value));
    return value.clamp(0.0, _maxIndex);
  }

  /// 选中块当前移动的“格/秒”速度，拖动时用帧间位移估算。
  double get _speedInCells {
    if (_dragging) {
      // 60fps 下每帧跨 0.28 格约等于 17 格/秒。
      return _dragDeltaIndex.abs() / 0.28 * 17.0;
    }
    if (!_controller.isAnimating) return 0.0;
    final delta = _tween.end! - _tween.begin!;
    if (delta == 0) return 0.0;
    const step = 0.004;
    final t = _controller.value;
    final t2 = math.min(1.0, t + step);
    final slope =
        (_springCurve.transform(t2) - _springCurve.transform(t)) / (t2 - t);
    final seconds = _switchDuration.inMilliseconds / 1000.0;
    // 起步 90ms 内让拉伸渐入，避免块在 t=0 一下“弹”宽。
    final elapsedMs = t * _switchDuration.inMilliseconds;
    final ramp = (elapsedMs / 90.0).clamp(0.0, 1.0);
    return (delta * slope / seconds).abs() * ramp;
  }

  /// 拉伸完全跟着速度走：动得快就拉长，停下来立刻回到原尺寸。
  double get _stretch {
    final speed = _speedInCells;
    if (speed <= 0.01) return 1.0;
    return 1.0 + _stretchMax * (speed / 14.0).clamp(0.0, 1.0);
  }

  /// 只有按住“当前选中项”或拖动时，选中块才缩小。
  bool get _holding => _dragging || _pressedIndex == widget.currentIndex;

  @override
  void didUpdateWidget(FloatingGlassNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      if (!_dragging && _controller.isAnimating) {
        final target = widget.currentIndex.toDouble();
        if ((_tween.end! - target).abs() < 0.001) return;
      }
      _animateTo(widget.currentIndex.toDouble());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _animateTo(double target) {
    final from = _position;
    if ((from - target).abs() < 0.001 && !_dragging) {
      _tween = Tween<double>(begin: target, end: target);
      _controller.value = 1.0;
      return;
    }
    _tween = Tween<double>(begin: from, end: target);
    _controller.forward(from: 0.0);
  }

  void _handleDragStart(DragStartDetails details) {
    if (_cellWidth <= 0 || _count == 0) return;
    final anchor = _position.round().clamp(0, _count - 1);
    final anchorCenter = _cellWidth * (anchor + 0.5);
    final dx = details.localPosition.dx;
    if ((dx - anchorCenter).abs() > _cellWidth * 0.6) {
      // 起手不在选中块上：很可能是一次带横向抖动的点击。
      // 先记下按到的格子，手指出 24px 再作废。
      _pendingTapIndex = (dx / _cellWidth).floor().clamp(0, _count - 1);
      _pendingTapDx = 0.0;
      return;
    }
    _pendingTapIndex = -1;
    // 从“当前看到的那个位置”接着走，动画中途再次按下也不会跳回去。
    _controller.stop();
    _dragStartIndex = _position;
    _dragIndex = _dragStartIndex;
    _dragDx = 0.0;
    _dragDeltaIndex = 0.0;
    setState(() {
      _dragging = true;
    });
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (_pendingTapIndex >= 0) {
      _pendingTapDx += details.delta.dx;
      if (_pendingTapDx.abs() > 24.0) {
        _pendingTapIndex = -1;
      }
      return;
    }
    if (!_dragging || _cellWidth <= 0) return;
    // 纯相对位移：选中块永远跟着手指走，不会先跳到手指底下。
    _dragDx += details.delta.dx;
    final next = (_dragStartIndex + _dragDx / _cellWidth).clamp(0.0, _maxIndex);
    _dragDeltaIndex = _dragDeltaIndex * 0.55 + (next - _dragIndex) * 0.45;
    final previous = _dragIndex.round();
    final current = next.round();
    if (previous != current && mounted) {
      HapticUtil.selectionClick();
    }
    setState(() {
      _dragIndex = next;
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_pendingTapIndex >= 0) {
      final target = _pendingTapIndex;
      _pendingTapIndex = -1;
      if (target != widget.currentIndex) {
        widget.onDestinationSelected(target);
      }
      return;
    }
    if (!_dragging) return;
    final frozen = _dragIndex;
    // 把当前位置钉成下一次动画的起点，避免回弹时跳一下。
    _tween = Tween<double>(begin: frozen, end: frozen);
    _controller.value = 0.0;
    setState(() {
      _dragging = false;
      _dragDeltaIndex = 0.0;
    });
    final target = frozen.round();
    _animateTo(target.toDouble());
    if (target != widget.currentIndex) {
      widget.onDestinationSelected(target);
    }
  }

  void _handleDragCancel() {
    _pendingTapIndex = -1;
    if (!_dragging) return;
    final frozen = _dragIndex;
    _tween = Tween<double>(begin: frozen, end: frozen);
    _controller.value = 0.0;
    setState(() {
      _dragging = false;
      _dragDeltaIndex = 0.0;
    });
    _animateTo(frozen.round().toDouble());
  }

  void _setPressed(int index, bool value) {
    if (value == (_pressedIndex == index)) return;
    setState(() {
      _pressedIndex = value ? index : -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    // 磨砂玻璃：底色是一层 75% 的雾面，再靠 BackdropFilter 把背后的内容
    // 糊开，深浅色各一套。
    final barColor = isDark
        ? const Color(0xFF0C0C10).withValues(alpha: 0.75)
        : Colors.white.withValues(alpha: 0.75);

    return Padding(
      padding: EdgeInsets.only(
        left: widget.horizontalMargin,
        right: widget.horizontalMargin,
        bottom: FloatingGlassNavBar._bottomGap(
          MediaQuery.of(context),
          widget.bottomMargin,
        ),
      ),
      child: SizedBox(
        height: widget.height,
        child: CustomPaint(
          // 阴影只画在栏的轮廓外侧：如果直接铺在玻璃下面，半透明的栏会
          // 把阴影透上来，栏内自己就发灰了。
          painter: _BarShadowPainter(radius: widget.height / 2, isDark: isDark),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.height / 2),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: widget.blurSigma,
                sigmaY: widget.blurSigma,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: BorderRadius.circular(widget.height / 2),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // 每格等分整条栏，选中块在格内四边内缩 _inset，
                    // 这样块的圆心永远正对图标，首尾两格也不会跑偏。
                    final cellWidth = math.max(
                      0.0,
                      constraints.maxWidth / _count,
                    );
                    _cellWidth = cellWidth;
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onHorizontalDragStart: _handleDragStart,
                      onHorizontalDragUpdate: _handleDragUpdate,
                      onHorizontalDragEnd: _handleDragEnd,
                      onHorizontalDragCancel: _handleDragCancel,
                      child: AnimatedBuilder(
                        animation: _controller,
                        builder: (context, _) => Stack(
                          children: [
                            _buildIndicator(isDark, constraints.maxHeight),
                            Row(
                              children: [
                                for (var i = 0; i < _count; i++)
                                  Expanded(
                                    child: _buildItem(context, i, cellWidth),
                                  ),
                              ],
                            ),
                            // 描边：亮底/深色图上都靠它定出栏的边界。
                            Positioned.fill(
                              child: IgnorePointer(
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                      widget.height / 2,
                                    ),
                                    border: Border.all(
                                      color: isDark
                                          ? Colors.white.withValues(alpha: 0.26)
                                          : Colors.white.withValues(
                                              alpha: 0.72,
                                            ),
                                      width: 1.2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIndicator(bool isDark, double boxHeight) {
    final cellWidth = _cellWidth;
    if (cellWidth <= 0 || boxHeight <= 0) {
      return const SizedBox.shrink();
    }
    final width = math.max(0.0, cellWidth - _inset * 2);
    // 高度按栏内实际可用高度算（外层 1px 描边会吃掉内容区），
    // 再用 (boxHeight - height) / 2 定位，上下留白必然相等。
    final height = math.max(0.0, boxHeight - _inset * 2);
    // 以格中心定位，块必然和图标同心。
    final left = cellWidth * (_position + 0.5) - width / 2;
    return Positioned(
      left: left,
      top: (boxHeight - height) / 2,
      width: width,
      height: height,
      child: IgnorePointer(
        // 给测试用的锚点：把块的标称矩形暴露出来，方便断言位置连续。
        key: const ValueKey('glassNavIndicator'),
        child: TweenAnimationBuilder<double>(
          // 按住时缩到 0.92，松开平滑涨回来，不会“啪”地跳一下。
          tween: Tween<double>(begin: 0.0, end: _holding ? 1.0 : 0.0),
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          builder: (context, press, child) {
            final squeeze = 1.0 - 0.08 * press;
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..scaleByDouble(_stretch, squeeze, 1.0, 1.0),
              child: child,
            );
          },
          child: DecoratedBox(
            decoration: BoxDecoration(
              // 回到“跟随背景”的淡色块：亮底上是极淡的黑、暗底上是极淡的白。
              color: isDark
                  ? Colors.white.withValues(alpha: 0.19)
                  : Colors.black.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(height / 2),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, int i, double cellWidth) {
    final destination = widget.destinations[i];
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // 选中时加深、加粗，未选中是中性灰。
    final strong = isDark ? const Color(0xFFF2F2F5) : const Color(0xFF141418);
    final weak = isDark ? const Color(0xFF9A9AA0) : const Color(0xFF8A8A90);

    final distance = (_position - i).abs().clamp(0.0, 1.0);
    final mix = Curves.easeIn.transform(
      ((distance - 0.18) / 0.42).clamp(0.0, 1.0),
    );
    final color = Color.lerp(strong, weak, mix)!;
    final selected = distance < 0.5;
    // 选中项的内容（图标+文字）放大 12%，随胶囊移动连续过渡。
    final contentScale = 1.0 + 0.12 * (1.0 - mix);

    return Semantics(
      button: true,
      selected: selected,
      label: destination.label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _setPressed(i, true),
        onTapUp: (_) => _setPressed(i, false),
        onTapCancel: () => _setPressed(i, false),
        onTap: () => widget.onDestinationSelected(i),
        child: Center(
          child: Transform.scale(
            scale: contentScale,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  selected
                      ? (destination.activeIcon ?? destination.icon)
                      : destination.icon,
                  size: 22,
                  color: color,
                ),
                const SizedBox(height: 2),
                SizedBox(
                  width: math.max(0.0, cellWidth - 8),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      destination.label,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 10.5,
                        height: 1.1,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        letterSpacing: 0.1,
                        color: color,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 欠阻尼弹簧从静止释放的位移响应。
///
/// 和 elasticOut 那类曲线不同，它满足 t=0 时位移与速度都为 0：
/// 选中块先加速、越过目标约 8%、再收回来，600ms 内静止，
/// 所以拖动松手和点击切换看起来是同一套物理。
/// 只在栏的轮廓外侧画阴影。
///
/// 直接用 BoxShadow 铺在玻璃下面时，半透明的栏会把阴影透上来，栏内自己就
/// 灰掉一档；这里把栏的圆角矩形从裁剪区里挖掉，保证投影只落在外面。
class _BarShadowPainter extends CustomPainter {
  const _BarShadowPainter({required this.radius, required this.isDark});

  final double radius;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final bar = Offset.zero & size;
    final outline = Path()
      ..addRRect(RRect.fromRectAndRadius(bar, Radius.circular(radius)));
    final outside = Path.combine(
      PathOperation.difference,
      Path()..addRect(bar.inflate(96)),
      outline,
    );

    canvas.save();
    canvas.clipPath(outside);
    void ring(double sigma, double alpha, Offset offset) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(bar.shift(offset), Radius.circular(radius)),
        Paint()
          ..color = Colors.black.withValues(alpha: alpha)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, sigma),
      );
    }

    // 一层大范围的环境影 + 一层贴边的硬影，围栏一圈。
    ring(24, isDark ? 0.55 : 0.16, const Offset(0, 6));
    ring(8, isDark ? 0.30 : 0.09, const Offset(0, 2));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _BarShadowPainter oldDelegate) {
    return oldDelegate.radius != radius || oldDelegate.isDark != isDark;
  }
}

class _SpringSettleCurve extends Curve {
  const _SpringSettleCurve();

  /// 固有角频率（rad/s）。
  static const double _omega = 9.5;

  /// 阻尼比，越小回弹越明显。
  static const double _zeta = 0.62;

  @override
  double transformInternal(double t) {
    if (t <= 0) return 0;
    if (t >= 1) return 1;
    final damped = _omega * math.sqrt(1 - _zeta * _zeta);
    final decay = math.exp(-_zeta * _omega * t);
    return 1 -
        decay *
            (math.cos(damped * t) +
                (_zeta * _omega / damped) * math.sin(damped * t));
  }
}
