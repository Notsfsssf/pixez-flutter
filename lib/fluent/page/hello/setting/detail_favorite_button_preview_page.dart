import 'dart:math' as math;

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/component/detail_favorite_button_location.dart';
import 'package:pixez/component/star_icon.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';

class DetailFavoriteButtonPreviewPage extends StatelessWidget {
  const DetailFavoriteButtonPreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: PageHeader(
        title: Text(I18n.of(context).detail_favorite_button_position("title")),
      ),
      content: Observer(
        builder: (context) => Stack(
          children: [
            _DetailPreviewSurface(),
            _FavoriteButtonPreview(),
            _FluentSliderPanel(),
          ],
        ),
      ),
    );
  }
}

class _FavoriteButtonPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final offset = detailFavoriteStackOffset(
            userSetting,
            Size(constraints.maxWidth, constraints.maxHeight),
            const Size(
              detailFavoriteButtonPreviewSize,
              detailFavoriteButtonPreviewSize,
            ),
          );
          return Stack(
            children: [
              Positioned(
                left: offset.dx,
                top: offset.dy,
                child: SizedBox(
                  width: detailFavoriteButtonPreviewSize,
                  height: detailFavoriteButtonPreviewSize,
                  child: Center(
                    child: ButtonTheme(
                      data: ButtonThemeData(
                        iconButtonStyle: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(
                            FluentTheme.of(context).inactiveBackgroundColor,
                          ),
                          shadowColor: WidgetStateProperty.all(
                            FluentTheme.of(context).shadowColor,
                          ),
                          shape: WidgetStateProperty.all(CircleBorder()),
                        ),
                      ),
                      child: IconButton(
                        icon: const StarIcon(state: 0),
                        onPressed: () {},
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DetailPreviewSurface extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    return ListView(
      padding: const EdgeInsets.only(bottom: 180),
      children: [
        Container(
          height: math.max(MediaQuery.of(context).size.height * 0.58, 360),
          color: theme.inactiveBackgroundColor,
          alignment: Alignment.center,
          child: Icon(
            FluentIcons.picture,
            size: 72,
            color: theme.inactiveColor,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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

class _FluentSliderPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 16,
      right: 16,
      bottom: 16,
      child: Container(
        decoration: BoxDecoration(
          color: FluentTheme.of(context).cardColor,
          border: Border.all(color: FluentTheme.of(context).inactiveColor),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: FluentTheme.of(context).shadowColor,
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
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
        SizedBox(width: 90, child: Text(label)),
        Expanded(
          child: Slider(value: value, min: 0, max: 1, onChanged: onChanged),
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
          color: FluentTheme.of(context).inactiveColor,
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
        color: FluentTheme.of(context).inactiveBackgroundColor,
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }
}
