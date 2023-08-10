import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:pixez/constants.dart';

/// 初始化滚动懒加载
///
/// 因为鼠标滚轮不能滚出视图，无法触发EazyRefresh，所以需要使用这个方法来
/// 为桌面平台提供更好的体验
void Function()? initializeScrollController(
  ScrollController controller,
  Future Function() next,
) {
  if (!Constants.isDesktop) return null;

  final listener = () async {
    if (controller.position.extentAfter > Constants.lazyLoadSize) return;

    await next();
  };

  controller.addListener(listener);
  return () => controller.removeListener(listener);
}
