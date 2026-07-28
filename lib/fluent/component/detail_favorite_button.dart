import 'dart:math' as math;

import 'package:fluent_ui/fluent_ui.dart';
import 'package:pixez/fluent/component/context_menu.dart';
import 'package:pixez/store/user_setting.dart';

const double _detailFavoriteButtonMargin = 8.0;
const double detailFavoriteButtonSize = 48.0;

class DetailFavoriteButton extends StatelessWidget {
  const DetailFavoriteButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.menuItems = const <MenuFlyoutItemBase>[],
  });

  final Widget icon;
  final VoidCallback? onPressed;
  final List<MenuFlyoutItemBase> menuItems;

  @override
  Widget build(BuildContext context) {
    final button = ButtonTheme(
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
      child: IconButton(icon: icon, onPressed: onPressed),
    );

    return SizedBox(
      width: detailFavoriteButtonSize,
      height: detailFavoriteButtonSize,
      child: Center(
        child: menuItems.isEmpty
            ? button
            : ContextMenu(child: button, items: menuItems),
      ),
    );
  }
}

extension DetailFavoriteFluentButtonSetting on UserSetting {
  Alignment detailFavoriteStackAlignment() {
    return detailFavoriteButtonLeft
        ? Alignment.bottomLeft
        : Alignment.bottomRight;
  }

  EdgeInsets detailFavoriteStackMargin() {
    return detailFavoriteButtonLeft
        ? const EdgeInsets.only(
            left: _detailFavoriteButtonMargin,
            bottom: _detailFavoriteButtonMargin,
          )
        : const EdgeInsets.only(
            right: _detailFavoriteButtonMargin,
            bottom: _detailFavoriteButtonMargin,
          );
  }

  Offset detailFavoriteStackOffset({
    required Size areaSize,
    Size childSize = const Size(
      detailFavoriteButtonSize,
      detailFavoriteButtonSize,
    ),
  }) {
    return detailFavoriteFractionalOffset(
      x: detailFavoriteButtonX,
      y: detailFavoriteButtonY,
      areaSize: areaSize,
      childSize: childSize,
    );
  }

  Offset detailFavoriteFractionalOffset({
    required double x,
    required double y,
    required Size areaSize,
    required Size childSize,
    double margin = _detailFavoriteButtonMargin,
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
    double margin = _detailFavoriteButtonMargin,
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
    return value.clamp(0.0, 1.0).toDouble();
  }
}
