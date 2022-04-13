import 'package:fluent_ui/fluent_ui.dart';

abstract class InkWellMode {
  static const int none = 0;
  static const int focusBorderOnly = 1 << 0;
  static const int cardOnly = 1 << 1;
  static const int all = focusBorderOnly | cardOnly;
}

/// Material 的 InkWell 垫片 用来为Fluent UI适配的
class InkWell extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final Function()? onTap;
  final Function()? onLongPress;
  final bool isTappable;
  final bool isHoverable;

  /// 决定其内部的组件组合方式 值应从 [InkWellMode] 中取
  final int mode;

  /// Material 的 InkWell垫片 用来为Fluent UI适配的
  InkWell({
    required this.child,
    this.onTap,
    this.onLongPress,
    this.margin,
    this.mode = InkWellMode.all,
    this.isTappable = true,
    this.isHoverable = true,
  });

  @override
  Widget build(BuildContext context) {
    return HoverButton(
      onPressed: isTappable ? onTap : _empty,
      onLongPress: onLongPress,
      margin: margin,
      builder: _buildContent,
    );
  }

  static _empty() {}

  Widget _buildContent(BuildContext context, Set<ButtonStates> state) {
    Widget content = child;
    if (checkEnum(mode, InkWellMode.cardOnly)) {
      content = Card(
        padding: const EdgeInsets.all(8.0),
        elevation: 0,
        backgroundColor: backgroundColor(
          FluentTheme.of(context),
          state,
        ),
        child: content,
      );
    }
    if (checkEnum(mode, InkWellMode.focusBorderOnly)) {
      content = FocusBorder(
        focused: state.isFocused || state.isHovering,
        child: content,
      );
    }

    return content;
  }

  static bool checkEnum(int a, int b) => (a & b) == b;

  Color backgroundColor(ThemeData style, Set<ButtonStates> states) {
    states = {
      if (states.isPressing && isHoverable && isTappable) ButtonStates.pressing,
      if (states.isHovering && isHoverable) ButtonStates.hovering,
      if (states.isFocused && isHoverable) ButtonStates.focused,
    };
    return ExpanderState.backgroundColor(
      style,
      states,
    );
  }
}
