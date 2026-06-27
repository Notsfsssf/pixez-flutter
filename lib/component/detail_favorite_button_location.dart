import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pixez/store/user_setting.dart';

const double detailFavoriteButtonMargin = 8.0;
const double detailFavoriteButtonPreviewSize = 48.0;

FloatingActionButtonLocation detailFavoriteFabLocation(UserSetting setting) {
  if (!setting.detailFavoriteButtonCustom) {
    return setting.detailFavoriteButtonLeft
        ? FloatingActionButtonLocation.startFloat
        : FloatingActionButtonLocation.endFloat;
  }
  return _DetailFavoriteFloatingActionButtonLocation(
    x: setting.detailFavoriteButtonX,
    y: setting.detailFavoriteButtonY,
  );
}

Alignment detailFavoriteStackAlignment(UserSetting setting) {
  return setting.detailFavoriteButtonLeft
      ? Alignment.bottomLeft
      : Alignment.bottomRight;
}

EdgeInsets detailFavoriteStackMargin(UserSetting setting) {
  return setting.detailFavoriteButtonLeft
      ? const EdgeInsets.only(
          left: detailFavoriteButtonMargin,
          bottom: detailFavoriteButtonMargin,
        )
      : const EdgeInsets.only(
          right: detailFavoriteButtonMargin,
          bottom: detailFavoriteButtonMargin,
        );
}

Offset detailFavoriteStackOffset(
  UserSetting setting,
  Size areaSize,
  Size childSize,
) {
  return detailFavoriteFractionalOffset(
    x: setting.detailFavoriteButtonX,
    y: setting.detailFavoriteButtonY,
    areaSize: areaSize,
    childSize: childSize,
  );
}

Offset detailFavoriteFractionalOffset({
  required double x,
  required double y,
  required Size areaSize,
  required Size childSize,
  double margin = detailFavoriteButtonMargin,
}) {
  final maxX = math.max(margin, areaSize.width - childSize.width - margin);
  final maxY = math.max(margin, areaSize.height - childSize.height - margin);
  final safeX = _clampPercent(x);
  final safeY = _clampPercent(y);
  return Offset(
    margin + (maxX - margin) * safeX,
    margin + (maxY - margin) * safeY,
  );
}

double _clampPercent(double value) => value.clamp(0.0, 1.0).toDouble();

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
      minX + (maxX - minX) * _clampPercent(x),
      minY + (maxY - minY) * _clampPercent(y),
    );
  }
}
