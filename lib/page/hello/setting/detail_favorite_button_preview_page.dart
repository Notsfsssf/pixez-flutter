import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/component/detail_favorite_button_location.dart';
import 'package:pixez/component/star_icon.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';

class DetailFavoriteButtonPreviewPage extends StatelessWidget {
  const DetailFavoriteButtonPreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) => Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            I18n.of(context).detail_favorite_button_position("title"),
          ),
        ),
        floatingActionButtonLocation: detailFavoriteFabLocation(userSetting),
        floatingActionButtonAnimator: FloatingActionButtonAnimator.noAnimation,
        floatingActionButton: FloatingActionButton(
          heroTag: null,
          backgroundColor: Colors.white,
          onPressed: () {},
          child: const StarIcon(state: 0),
        ),
        body: Stack(
          children: [_DetailPreviewSurface(), _MaterialSliderPanel()],
        ),
      ),
    );
  }
}

class _DetailPreviewSurface extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            height: math.max(MediaQuery.of(context).size.height * 0.58, 360),
            color: colorScheme.surfaceContainerHighest,
            alignment: Alignment.center,
            child: Icon(
              Icons.image_outlined,
              size: 72,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 180),
          sliver: SliverList.list(
            children: [
              _Line(widthFactor: 0.72, height: 18),
              const SizedBox(height: 16),
              _Line(widthFactor: 1),
              const SizedBox(height: 8),
              _Line(widthFactor: 0.86),
              const SizedBox(height: 20),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: const [
                  _ChipLine(width: 68),
                  _ChipLine(width: 92),
                  _ChipLine(width: 76),
                ],
              ),
              const SizedBox(height: 28),
              _Line(widthFactor: 0.42, height: 14),
              const SizedBox(height: 12),
              _Line(widthFactor: 1),
              const SizedBox(height: 8),
              _Line(widthFactor: 0.94),
              const SizedBox(height: 8),
              _Line(widthFactor: 0.78),
            ],
          ),
        ),
      ],
    );
  }
}

class _MaterialSliderPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom + 16;
    return Positioned(
      left: 16,
      right: 16,
      bottom: bottom,
      child: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(8),
        color: Theme.of(context).colorScheme.surface,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _SliderRow(
                label: I18n.of(
                  context,
                ).detail_favorite_button_position("horizontal"),
                value: userSetting.detailFavoriteButtonCustomX,
                onChanged: userSetting.setDetailFavoriteButtonCustomX,
              ),
              _SliderRow(
                label: I18n.of(
                  context,
                ).detail_favorite_button_position("vertical"),
                value: userSetting.detailFavoriteButtonCustomY,
                onChanged: userSetting.setDetailFavoriteButtonCustomY,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  const _SliderRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 72, child: Text(label)),
        Expanded(
          child: Slider(value: value, onChanged: onChanged),
        ),
      ],
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.widthFactor, this.height = 12});

  final double widthFactor;
  final double height;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      alignment: Alignment.centerLeft,
      widthFactor: widthFactor,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.outlineVariant,
          borderRadius: BorderRadius.circular(height / 2),
        ),
      ),
    );
  }
}

class _ChipLine extends StatelessWidget {
  const _ChipLine({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 28,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }
}
