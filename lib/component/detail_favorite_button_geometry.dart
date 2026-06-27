import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:pixez/store/user_setting.dart';

const double detailFavoriteButtonMargin = 8.0;
const double detailFavoriteButtonPreviewSize = 48.0;

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
  final safeX = detailFavoriteClampPercent(x);
  final safeY = detailFavoriteClampPercent(y);
  return Offset(
    margin + (maxX - margin) * safeX,
    margin + (maxY - margin) * safeY,
  );
}

double detailFavoriteClampPercent(double value) {
  return value.clamp(0.0, 1.0).toDouble();
}
