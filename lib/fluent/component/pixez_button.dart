import 'package:fluent_ui/fluent_ui.dart';

class PixEzButton extends StatelessWidget {
  final Widget child;
  final void Function() onPressed;
  final bool noPadding;

  const PixEzButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.noPadding = false,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: noPadding ? EdgeInsets.zero : const EdgeInsets.all(4.0),
        child: ButtonTheme(
          data: ButtonThemeData(
            iconButtonStyle: ButtonStyle(
              padding: WidgetStateProperty.all(EdgeInsets.zero),
            ),
          ),
          child: IconButton(
            icon: ClipRRect(
              borderRadius: const BorderRadius.all(const Radius.circular(4.0)),
              child: child,
            ),
            onPressed: onPressed,
          ),
        ),
      );
}
