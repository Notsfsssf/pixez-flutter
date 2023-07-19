import 'package:fluent_ui/fluent_ui.dart';

class FocusWrap extends StatefulWidget {
  final Widget child;
  final void Function() onInvoke;
  final bool? renderOutside;

  FocusWrap(
      {super.key,
      required this.child,
      required this.onInvoke,
      this.renderOutside});

  @override
  State<StatefulWidget> createState() => _FocusWrapState();
}

class _FocusWrapState extends State<FocusWrap> {
  bool _shouldShowFocus = false;
  @override
  Widget build(BuildContext context) => Padding(
        padding: widget.renderOutside != null
            ? EdgeInsets.zero
            : const EdgeInsets.all(2.0),
        child: FocusableActionDetector(
          child: FocusBorder(
            child: widget.child,
            focused: _shouldShowFocus,
            renderOutside: widget.renderOutside,
          ),
          onShowFocusHighlight: (v) {
            if (mounted) setState(() => _shouldShowFocus = v);
          },
          actions: {
            ActivateIntent: CallbackAction<ActivateIntent>(
              onInvoke: (intent) => widget.onInvoke(),
            ),
          },
        ),
      );
}
