import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pixez/store/user_setting.dart';

const double detailFavoriteFloatingActionButtonSize = 56.0;

class DetailFavoriteButton extends StatelessWidget {
  const DetailFavoriteButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.heroTag,
    this.backgroundColor,
  });

  final Widget icon;
  final VoidCallback? onPressed;
  final Object? heroTag;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: heroTag,
      backgroundColor: backgroundColor,
      onPressed: onPressed,
      child: icon,
    );
  }
}

extension DetailFavoriteMaterialButtonSetting on UserSetting {
  Offset detailFavoriteFractionalOffset({
    required double x,
    required double y,
    required Size areaSize,
    required Size childSize,
    double margin = kFloatingActionButtonMargin,
  }) {
    final maxX = math.max(margin, areaSize.width - childSize.width - margin);
    final maxY = math.max(margin, areaSize.height - childSize.height - margin);
    final safeX = detailFavoriteClampPercent(x);
    final safeY = detailFavoriteClampPercent(y);
    return Offset(
      margin + (maxX - margin) * safeX,
      margin + (maxY - margin) * safeY,
    );
  }

  Offset detailFavoriteFractionalPositionFromOffset({
    required Offset offset,
    required Size areaSize,
    required Size childSize,
    double margin = kFloatingActionButtonMargin,
  }) {
    final maxX = math.max(margin, areaSize.width - childSize.width - margin);
    final maxY = math.max(margin, areaSize.height - childSize.height - margin);
    final rangeX = math.max(1.0, maxX - margin);
    final rangeY = math.max(1.0, maxY - margin);
    return Offset(
      detailFavoriteClampPercent((offset.dx - margin) / rangeX),
      detailFavoriteClampPercent((offset.dy - margin) / rangeY),
    );
  }

  double detailFavoriteClampPercent(double value) {
    return _detailFavoriteClampPercent(value);
  }

  FloatingActionButtonLocation detailFavoriteFabLocation() {
    if (!detailFavoriteButtonCustom) {
      return detailFavoriteButtonLeft
          ? FloatingActionButtonLocation.startFloat
          : FloatingActionButtonLocation.endFloat;
    }
    return _DetailFavoriteFloatingActionButtonLocation(
      x: detailFavoriteButtonX,
      y: detailFavoriteButtonY,
    );
  }
}

double _detailFavoriteClampPercent(double value) {
  return value.clamp(0.0, 1.0).toDouble();
}

class _DetailFavoriteFloatingActionButtonLocation
    extends FloatingActionButtonLocation {
  const _DetailFavoriteFloatingActionButtonLocation({
    required this.x,
    required this.y,
  });

  final double x;
  final double y;

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final fabSize = scaffoldGeometry.floatingActionButtonSize;
    final minX = kFloatingActionButtonMargin + scaffoldGeometry.minInsets.left;
    final maxX = math.max(
      minX,
      scaffoldGeometry.scaffoldSize.width -
          fabSize.width -
          kFloatingActionButtonMargin -
          scaffoldGeometry.minInsets.right,
    );
    final minY = kFloatingActionButtonMargin + scaffoldGeometry.minInsets.top;
    final bottomLimit = math.min(
      scaffoldGeometry.scaffoldSize.height,
      scaffoldGeometry.contentBottom,
    );
    final maxY = math.max(
      minY,
      bottomLimit -
          fabSize.height -
          kFloatingActionButtonMargin -
          scaffoldGeometry.minInsets.bottom,
    );

    return Offset(
      minX + (maxX - minX) * _detailFavoriteClampPercent(x),
      minY + (maxY - minY) * _detailFavoriteClampPercent(y),
    );
  }
}
