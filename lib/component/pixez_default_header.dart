import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:pixez/i18n.dart';

class PixezDefault {
  static Header header(BuildContext context,
      {IndicatorPosition position = IndicatorPosition.above,
      bool safeArea = true}) {
    return MaterialHeader(
        position: position,
        safeArea: safeArea,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor);
  }

  static Footer footer(BuildContext context,
      {IndicatorPosition position = IndicatorPosition.above}) {
    return ClassicFooter(
        position: position,
        processingText: I18n.of(context).footer_loading,
        failedText: I18n.of(context).failed,
        noMoreText: I18n.of(context).no_more,
        showMessage: false,
        processedText: I18n.of(context).successed);
  }
}
