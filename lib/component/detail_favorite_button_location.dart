import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pixez/component/detail_favorite_button_geometry.dart';
import 'package:pixez/store/user_setting.dart';

export 'package:pixez/component/detail_favorite_button_geometry.dart';

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
      minX + (maxX - minX) * detailFavoriteClampPercent(x),
      minY + (maxY - minY) * detailFavoriteClampPercent(y),
    );
  }
}
