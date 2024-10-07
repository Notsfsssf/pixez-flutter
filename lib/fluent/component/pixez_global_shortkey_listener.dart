import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';

class PixEzGlobalShortkeyListener extends StatelessWidget {
  final Widget child;
  final Function() goBack;

  const PixEzGlobalShortkeyListener({
    super.key,
    required this.child,
    required this.goBack,
  });

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      child: Listener(
        child: child,
        onPointerDown: (event) {
          // 鼠标的后退按钮
          if (event.buttons == kBackMouseButton &&
              event.kind == PointerDeviceKind.mouse) goBack();
        },
      ),
      onKeyEvent: (value) {
        if (value is KeyUpEvent) {
          // 键盘的 Alt + 左箭头
          if (HardwareKeyboard.instance.isAltPressed &&
              value.logicalKey == LogicalKeyboardKey.arrowLeft) goBack();
        }
      },
    );
  }
}
