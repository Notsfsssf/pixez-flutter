import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pixez/component/ugoira_painter.dart';
import 'package:pixez/desktop/window_full_screen.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/models/illust.dart';
import 'package:pixez/page/picture/ugoira_store.dart';

/// Plays a downloaded ugoira fitted to the window on a black background, like
/// the photo viewer does for still images.
class UgoiraFullscreenPage extends StatefulWidget {
  const UgoiraFullscreenPage({
    super.key,
    required this.illusts,
    required this.store,
    required this.onActions,
  });

  final Illusts illusts;
  final UgoiraStore store;

  /// Opens the encode/export choices, the same as right-click on the cover.
  final VoidCallback onActions;

  @override
  State<UgoiraFullscreenPage> createState() => _UgoiraFullscreenPageState();
}

class _UgoiraFullscreenPageState extends State<UgoiraFullscreenPage> {
  bool _windowFullScreen = false;
  bool _enteredHere = false;

  @override
  void initState() {
    super.initState();
    WindowFullScreen.isActive.then((value) {
      if (mounted) setState(() => _windowFullScreen = value);
    });
  }

  @override
  void dispose() {
    // Closing the viewer returns the window to how the user had it.
    if (_enteredHere) WindowFullScreen.set(false);
    super.dispose();
  }

  Future<void> _toggleWindowFullScreen() async {
    final value = await WindowFullScreen.toggle();
    _enteredHere = value;
    if (mounted) setState(() => _windowFullScreen = value);
  }

  /// Esc leaves window full screen first, then closes the viewer.
  Future<void> _escape() async {
    if (await WindowFullScreen.isActive) {
      await _toggleWindowFullScreen();
    } else if (mounted) {
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final metadata = widget.store.ugoiraMetadataResponse!;
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): _escape,
        const SingleActivator(LogicalKeyboardKey.keyF): _toggleWindowFullScreen,
        const SingleActivator(
          LogicalKeyboardKey.keyF,
          meta: true,
          control: true,
        ): _toggleWindowFullScreen,
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          backgroundColor: Colors.black,
          // Expand so the toolbar, the only non-positioned child before,
          // can't size the stack (and the ugoira) down to its own height.
          body: Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: GestureDetector(
                  onSecondaryTap: widget.onActions,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final ratio =
                          widget.illusts.width / widget.illusts.height;
                      var width = constraints.maxWidth;
                      var height = width / ratio;
                      if (height > constraints.maxHeight) {
                        height = constraints.maxHeight;
                        width = height * ratio;
                      }
                      return Center(
                        child: UgoiraWidget(
                          delay: metadata.ugoiraMetadata.frames.first.delay,
                          ugoiraMetadataResponse: metadata,
                          size: Size(width, height),
                          drawPools: widget.store.drawPool,
                        ),
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        IconButton(
                          tooltip: MaterialLocalizations.of(
                            context,
                          ).closeButtonTooltip,
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.of(context).maybePop(),
                        ),
                        const Spacer(),
                        IconButton(
                          tooltip: I18n.of(context).encode,
                          icon: const Icon(
                            Icons.gif_box_outlined,
                            color: Colors.white,
                          ),
                          onPressed: widget.onActions,
                        ),
                        IconButton(
                          tooltip: 'F',
                          icon: Icon(
                            _windowFullScreen
                                ? Icons.fullscreen_exit
                                : Icons.fullscreen,
                            color: Colors.white,
                          ),
                          onPressed: _toggleWindowFullScreen,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
