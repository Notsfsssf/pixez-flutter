import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';

/// 当使用鼠标滚轮滚动时 距离底边还有多少距离时开始加载下一页
const double kLazyLoadSize = 300;

/// 初始化滚动懒加载
///
/// 因为鼠标滚轮不能滚出视图，无法触发EazyRefresh，所以需要使用这个方法来
/// 为桌面平台提供更好的体验
///
/// 这个方法返回一个用于注销监听器的方法
void Function()? initializeScrollController(
  ScrollController controller,
  Future Function() next,
) {
  if (!Platform.isWindows && !Platform.isMacOS && !Platform.isLinux)
    return null;

  final listener = () async {
    if (controller.position.extentAfter > kLazyLoadSize) return;

    await next();
  };

  controller.addListener(listener);
  return () => controller.removeListener(listener);
}
