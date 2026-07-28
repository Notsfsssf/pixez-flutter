import 'dart:math' as math;

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:pixez/component/star_icon.dart';
import 'package:pixez/fluent/component/detail_favorite_button.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';

class DetailFavoriteButtonPreviewPage extends StatefulWidget {
  const DetailFavoriteButtonPreviewPage({super.key});

  @override
  State<DetailFavoriteButtonPreviewPage> createState() =>
      _DetailFavoriteButtonPreviewPageState();
}

class _DetailFavoriteButtonPreviewPageState
    extends State<DetailFavoriteButtonPreviewPage> {
  late final ValueNotifier<Offset> _position;

  @override
  void initState() {
    super.initState();
    _position = ValueNotifier(
      Offset(
        userSetting.detailFavoriteButtonCustomX,
        userSetting.detailFavoriteButtonCustomY,
      ),
    );
  }

  @override
  void dispose() {
    _commitPosition();
    _position.dispose();
    super.dispose();
  }

  void _setPosition(Offset value) {
    _position.value = Offset(
      userSetting.detailFavoriteClampPercent(value.dx),
      userSetting.detailFavoriteClampPercent(value.dy),
    );
  }

  void _commitPosition() {
    final position = _position.value;
    userSetting.setDetailFavoriteButtonCustomX(position.dx);
    userSetting.setDetailFavoriteButtonCustomY(position.dy);
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      content: Stack(
        children: [
          _DetailPreviewSurface(),
          _FavoriteButtonPreview(
            position: _position,
            onChanged: _setPosition,
            onChangeEnd: _commitPosition,
          ),
        ],
      ),
    );
  }
}

class _FavoriteButtonPreview extends StatefulWidget {
  const _FavoriteButtonPreview({
    required this.position,
    required this.onChanged,
    required this.onChangeEnd,
  });

  final ValueListenable<Offset> position;
  final ValueChanged<Offset> onChanged;
  final VoidCallback onChangeEnd;

  @override
  State<_FavoriteButtonPreview> createState() => _FavoriteButtonPreviewState();
}

class _FavoriteButtonPreviewState extends State<_FavoriteButtonPreview> {
  Offset? _dragStartPosition;
  Offset? _dragStartPointer;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final areaSize = Size(constraints.maxWidth, constraints.maxHeight);
          const childSize = Size(
            detailFavoriteButtonSize,
            detailFavoriteButtonSize,
          );
          return ValueListenableBuilder<Offset>(
            valueListenable: widget.position,
            builder: (context, position, child) {
              final offset = userSetting.detailFavoriteFractionalOffset(
                x: position.dx,
                y: position.dy,
                areaSize: areaSize,
                childSize: childSize,
              );
              return Stack(
                children: [
                  Positioned(
                    left: offset.dx,
                    top: offset.dy,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.move,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onPanStart: (details) {
                          _dragStartPosition = position;
                          _dragStartPointer = details.globalPosition;
                        },
                        onPanUpdate: (details) {
                          final startPosition = _dragStartPosition ?? position;
                          final startPointer =
                              _dragStartPointer ?? details.globalPosition;
                          final startOffset = userSetting
                              .detailFavoriteFractionalOffset(
                                x: startPosition.dx,
                                y: startPosition.dy,
                                areaSize: areaSize,
                                childSize: childSize,
                              );
                          widget.onChanged(
                            userSetting
                                .detailFavoriteFractionalPositionFromOffset(
                                  offset:
                                      startOffset +
                                      details.globalPosition -
                                      startPointer,
                                  areaSize: areaSize,
                                  childSize: childSize,
                                ),
                          );
                        },
                        onPanEnd: (_) => _endDrag(),
                        onPanCancel: _endDrag,
                        child: child,
                      ),
                    ),
                  ),
                ],
              );
            },
            child: DetailFavoriteButton(
              icon: const StarIcon(state: 0),
              onPressed: () {},
            ),
          );
        },
      ),
    );
  }

  void _endDrag() {
    _dragStartPosition = null;
    _dragStartPointer = null;
    widget.onChangeEnd();
  }
}

class _DetailPreviewSurface extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > constraints.maxHeight;
        if (isWide && constraints.maxWidth >= 760) {
          final detailWidth = math.min(320.0, constraints.maxWidth * 0.36);
          return Row(
            children: [
              SizedBox(
                width: constraints.maxWidth - detailWidth,
                child: CustomScrollView(
                  slivers: [
                    SliverFillRemaining(
                      child: _PreviewImage(
                        height: constraints.maxHeight,
                        compact: true,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  color: FluentTheme.of(context).cardColor,
                  margin: const EdgeInsets.only(right: 4.0),
                  child: CustomScrollView(
                    slivers: _buildDetailSlivers(context, bottomPadding: 24),
                  ),
                ),
              ),
            ],
          );
        }

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _PreviewImage(
                height: math.max(constraints.maxHeight * 0.58, 360),
              ),
            ),
            ..._buildDetailSlivers(context, bottomPadding: 24),
          ],
        );
      },
    );
  }

  List<Widget> _buildDetailSlivers(
    BuildContext context, {
    required double bottomPadding,
  }) {
    return [
      SliverToBoxAdapter(child: _PreviewNameAvatar()),
      SliverToBoxAdapter(child: _PreviewStats()),
      SliverToBoxAdapter(child: _PreviewTags()),
      SliverToBoxAdapter(child: _PreviewCaption()),
      SliverToBoxAdapter(child: _PreviewCommentLink()),
      SliverToBoxAdapter(child: _PreviewAboutHeader()),
      _PreviewRecomGrid(),
      SliverToBoxAdapter(child: SizedBox(height: bottomPadding)),
    ];
  }
}

class _PreviewImage extends StatelessWidget {
  const _PreviewImage({required this.height, this.compact = false});

  final double height;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    return Container(
      height: height,
      color: theme.inactiveBackgroundColor,
      alignment: Alignment.center,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = math.min(
            math.min(
              constraints.maxWidth * (compact ? 0.82 : 0.78),
              compact ? 640.0 : 520.0,
            ),
            constraints.maxHeight * 0.72,
          );
          return SizedBox(
            width: width,
            child: AspectRatio(
              aspectRatio: 0.72,
              child: Container(
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: theme.inactiveColor.withValues(alpha: 0.28),
                  ),
                ),
                alignment: Alignment.center,
                child: Icon(
                  FluentIcons.picture,
                  size: 64,
                  color: theme.inactiveColor,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PreviewNameAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            height: 70,
            width: 70,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 70,
                  width: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.accentColor,
                  ),
                ),
                Container(
                  height: 58,
                  width: 58,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.inactiveBackgroundColor,
                  ),
                  child: Icon(
                    FluentIcons.account_browser,
                    color: theme.inactiveColor,
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _Line(widthFactor: 0.66, height: 16, accent: true),
                SizedBox(height: 10),
                _Line(widthFactor: 0.44),
                SizedBox(height: 8),
                _Line(widthFactor: 0.58, height: 10),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PreviewStats extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          _StatsRow(
            items: [
              _StatsItem(I18n.of(context).illust_id, "123456789"),
              _StatsItem(I18n.of(context).pixel, "2400x3600"),
            ],
          ),
          const SizedBox(height: 6),
          _StatsRow(
            items: [
              _StatsItem(I18n.of(context).total_view, "12,345"),
              _StatsItem(I18n.of(context).total_bookmark, "6,789"),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.items});

  final List<_StatsItem> items;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    return Wrap(
      spacing: 20,
      runSpacing: 6,
      children: [
        for (final item in items)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(item.label),
              const SizedBox(width: 10),
              Text(item.value, style: TextStyle(color: theme.accentColor)),
            ],
          ),
      ],
    );
  }
}

class _StatsItem {
  const _StatsItem(this.label, this.value);

  final String label;
  final String value;
}

class _PreviewTags extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          _TagPill(width: 72),
          _TagPill(width: 96),
          _TagPill(width: 80),
          _TagPill(width: 116),
        ],
      ),
    );
  }
}

class _PreviewCaption extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _Line(widthFactor: 1),
            SizedBox(height: 8),
            _Line(widthFactor: 0.92),
            SizedBox(height: 8),
            _Line(widthFactor: 0.64),
          ],
        ),
      ),
    );
  }
}

class _PreviewCommentLink extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: HyperlinkButton(
        onPressed: () {},
        child: Text(
          I18n.of(context).view_comment,
          style: FluentTheme.of(context).typography.body,
        ),
      ),
    );
  }
}

class _PreviewAboutHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(I18n.of(context).about_picture),
    );
  }
}

class _PreviewRecomGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      delegate: SliverChildBuilderDelegate(
        (context, index) => Padding(
          padding: const EdgeInsets.all(6.0),
          child: Container(
            decoration: BoxDecoration(
              color: FluentTheme.of(context).inactiveBackgroundColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              FluentIcons.picture,
              color: FluentTheme.of(context).inactiveColor,
            ),
          ),
        ),
        childCount: 6,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({
    required this.widthFactor,
    this.height = 12,
    this.accent = false,
  });

  final double widthFactor;
  final double height;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    return FractionallySizedBox(
      alignment: Alignment.centerLeft,
      widthFactor: widthFactor,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: accent ? theme.accentColor : theme.inactiveColor,
          borderRadius: BorderRadius.circular(height / 2),
        ),
      ),
    );
  }
}

class _TagPill extends StatelessWidget {
  const _TagPill({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 28,
      decoration: BoxDecoration(
        color: FluentTheme.of(context).inactiveBackgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
