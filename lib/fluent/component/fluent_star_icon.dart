import 'package:fluent_ui/fluent_ui.dart';

class FluentStarIcon extends StatelessWidget {
  const FluentStarIcon({super.key, required this.state});

  final int state;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    return SizedBox(
      width: 40,
      height: 40,
      child: Center(
        child: Icon(
          state == 0
              ? FluentIcons.favorite_star
              : FluentIcons.favorite_star_fill,
          color: state > 1 ? Colors.red : theme.resources.textFillColorPrimary,
        ),
      ),
    );
  }
}
