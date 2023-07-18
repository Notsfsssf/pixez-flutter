import 'package:fluent_ui/fluent_ui.dart';

class FocusWrap extends StatefulWidget {
  final Widget child;

  FocusWrap({super.key, required this.child});

  @override
  State<StatefulWidget> createState() => _FocusWrapState();
}

class _FocusWrapState extends State<FocusWrap> {
  bool _focus = false;
  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.all(2.0),
        child: Focus(
          onFocusChange: (v) => setState(() => _focus = v),
          child: FocusBorder(child: widget.child, focused: _focus),
        ),
      );
}
