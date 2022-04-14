import 'package:fluent_ui/fluent_ui.dart';

abstract class InkWellMode {
  static const int none = 0;
  static const int focusBorderOnly = 1 << 0;
  static const int cardOnly = 1 << 1;
  static const int all = focusBorderOnly | cardOnly;
}

bool checkEnum(int a, int b) => (a & b) == b;

/// Material 的 InkWell 垫片 用来为Fluent UI适配的
class InkWell extends StatelessWidget {
  /// Material 的 InkWell垫片 用来为Fluent UI适配的
  InkWell({
    Key? key,
    required this.child,
    this.cursor,
    this.focusNode,
    this.margin,
    this.semanticLabel,
    this.onTap,
    this.onLongPress,
    this.onTapDown,
    this.onTapUp,
    this.onTapCancel,
    this.onLongPressEnd,
    this.onLongPressStart,
    this.onHorizontalDragStart,
    this.onHorizontalDragUpdate,
    this.onHorizontalDragEnd,
    this.onFocusChange,
    this.autofocus = false,
    this.actionsEnabled = true,
    this.mode = InkWellMode.all,
    this.focusStyle,
    this.focusRenderOutside,
    this.useStackApproach = true,
    this.padding = const EdgeInsets.all(8.0),
    this.elevation = 0.0,
    this.borderRadius = const BorderRadius.all(Radius.circular(6.0)),
  }) : super(key: key);
  
  final MouseCursor? cursor;
  final VoidCallback? onLongPress;
  final VoidCallback? onLongPressStart;
  final VoidCallback? onLongPressEnd;

  final VoidCallback? onTap;
  final VoidCallback? onTapUp;
  final VoidCallback? onTapDown;
  final VoidCallback? onTapCancel;

  final GestureDragStartCallback? onHorizontalDragStart;
  final GestureDragUpdateCallback? onHorizontalDragUpdate;
  final GestureDragEndCallback? onHorizontalDragEnd;

  final ValueChanged<bool>? onFocusChange;
  final Widget child;
  final FocusNode? focusNode;
  final EdgeInsetsGeometry? margin;
  final String? semanticLabel;
  final bool autofocus;
  final bool actionsEnabled;

  final FocusThemeData? focusStyle;
  final bool? focusRenderOutside;
  final bool useStackApproach;

  final EdgeInsets padding;
  final double elevation;
  final BorderRadiusGeometry borderRadius;

  /// 决定其内部的组件组合方式 值应从 [InkWellMode] 中取
  final int mode;


  @override
  Widget build(BuildContext context) {
    return HoverButton(
      builder: _buildContent,
      cursor: cursor,
      focusNode: focusNode,
      margin: margin,
      semanticLabel: semanticLabel,
      onPressed: onTap,
      onLongPress: onLongPress,
      onTapDown: onTapDown,
      onTapUp: onTapUp,
      onTapCancel: onTapCancel,
      onLongPressEnd: onLongPressEnd,
      onLongPressStart: onLongPressStart,
      onHorizontalDragStart: onHorizontalDragStart,
      onHorizontalDragUpdate: onHorizontalDragUpdate,
      onHorizontalDragEnd: onHorizontalDragEnd,
      onFocusChange: onFocusChange,
      autofocus: autofocus,
      actionsEnabled: actionsEnabled,
    );
  }

  Widget _buildContent(BuildContext context, Set<ButtonStates> state) {
    Widget content = child;
    if (checkEnum(mode, InkWellMode.cardOnly)) {
      content = Card(
        child: content,
        padding: padding,
        backgroundColor:
            ExpanderState.backgroundColor(FluentTheme.of(context), state),
        elevation: elevation,
        borderRadius: borderRadius,
      );
    }
    if (checkEnum(mode, InkWellMode.focusBorderOnly)) {
      content = FocusBorder(
        child: content,
        focused: state.isFocused || state.isHovering,
        style: focusStyle,
        renderOutside: focusRenderOutside,
        useStackApproach: useStackApproach,
      );
    }
    return content;
  }
}
