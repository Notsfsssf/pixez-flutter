import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';

class PixezDefault {
  static Header header(BuildContext context,
      {IndicatorPosition position = IndicatorPosition.above,
      bool safeArea = true}) {
    return MaterialHeader(position: position, safeArea: safeArea);
  }

  static Footer footer(BuildContext context,
      {IndicatorPosition position = IndicatorPosition.above}) {
    return MaterialFooter(position: position);
  }
}
