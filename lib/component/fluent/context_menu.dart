import 'package:fluent_ui/fluent_ui.dart';

class ContextMenu extends StatefulWidget {
  final Widget child;
  final List<MenuFlyoutItemBase> items;

  ContextMenu({super.key, required this.child, required this.items});

  @override
  State<StatefulWidget> createState() => _ContextMenuState();
}

class _ContextMenuState extends State<ContextMenu> {
  final _key = GlobalKey();
  final _controller = FlyoutController();
  @override
  Widget build(BuildContext context) => FlyoutTarget(
        key: _key,
        controller: _controller,
        child: GestureDetector(
          child: widget.child,
          onSecondaryTapUp: (details) {
            _controller.showFlyout(
              position: _getPosition(context, details.localPosition),
              builder: (context) => MenuFlyout(items: widget.items),
            );
          },
        ),
      );

  Offset? _getPosition(
    BuildContext context,
    Offset localPosition,
  ) {
    // This calculates the position of the flyout according to the parent navigator
    final box = context.findRenderObject() as RenderBox;
    return box.localToGlobal(
      localPosition,
      ancestor: Navigator.of(context).context.findRenderObject(),
    );
  }
}
