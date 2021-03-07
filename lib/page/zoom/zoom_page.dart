/*
 * Copyright (C) 2020. by perol_notsf, All rights reserved
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program. If not, see <http://www.gnu.org/licenses/>.
 *
 */

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:pixez/component/pixiv_image.dart';

class ZoomPage extends StatefulWidget {
  final String url;

  const ZoomPage({Key? key, required this.url}) : super(key: key);

  @override
  _ZoomPageState createState() => _ZoomPageState();
}

class _ZoomPageState extends State<ZoomPage> {
  bool fabvisible = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: PinchZoomImage(
          image: PixivImage(widget.url),
          onZoomStart: () {
            print('Zoom started');
            setState(() {
              fabvisible = false;
            });
          },
          onZoomEnd: () {
            print('Zoom finished');
            setState(() {
              fabvisible = true;
            });
          },
        ),
      ),
      floatingActionButton: Visibility(
        visible: fabvisible,
        child: FloatingActionButton(
          child: Icon(Icons.flip_to_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }
}

class PinchZoomImage extends StatefulWidget {
  final Widget image;
  final Color zoomedBackgroundColor;
  final Function? onZoomStart;
  final Function? onZoomEnd;

  PinchZoomImage({
    required this.image,
    this.zoomedBackgroundColor = Colors.transparent,
    this.onZoomStart,
    this.onZoomEnd,
  });

  @override
  _PinchZoomImageState createState() => _PinchZoomImageState();
}

class _PinchZoomImageState extends State<PinchZoomImage> {
  OverlayEntry? overlayEntry;
  Offset? scaleStartPosition;
  Offset? origin;
  int numPointers = 0;
  bool zooming = false;
  bool reversing = false;
  GlobalKey<PinchZoomOverlayImageState> overlayKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => numPointers++,
      onPointerUp: (_) => numPointers--,
      child: GestureDetector(
        onScaleStart: _handleScaleStart,
        onScaleUpdate: _handleScaleUpdate,
        onScaleEnd: _handleScaleEnd,
        child: Stack(
          overflow: Overflow.clip,
          children: <Widget>[
            Opacity(
              opacity: zooming ? 0.0 : 1.0,
              child: widget.image,
            ),
            Positioned(
              top: 0.0,
              left: 0.0,
              right: 0.0,
              bottom: 0.0,
              child: Container(
                color:
                    zooming ? widget.zoomedBackgroundColor : Colors.transparent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleScaleStart(ScaleStartDetails details) {
    if (overlayEntry != null || reversing || numPointers < 2) return;
    setState(() {
      zooming = true;
    });
    if (widget.onZoomStart != null) widget.onZoomStart!();
    OverlayState overlayState = Overlay.of(context)!;
    double width = context.size!.width;
    double height = context.size!.height;
    origin = (context.findRenderObject() as RenderBox)
        .localToGlobal(Offset(0.0, 0.0));
    scaleStartPosition = details.focalPoint;

    overlayEntry = OverlayEntry(
      maintainState: true,
      builder: (BuildContext context) {
        return PinchZoomOverlayImage(
          key: overlayKey,
          height: height,
          width: width,
          origin: origin!,
          image: widget.image,
        );
      },
    );

    overlayState.insert(overlayEntry!);
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    if (reversing || numPointers < 2) return;
    overlayKey?.currentState
        ?.updatePosition(origin! - (scaleStartPosition! - details.focalPoint));
    if (details.scale >= 1.0)
      overlayKey?.currentState?.updateScale(details.scale);
  }

  void _handleScaleEnd(ScaleEndDetails details) async {
    if (reversing || !zooming) return;
    reversing = true;
    if (widget.onZoomEnd != null) widget.onZoomEnd!();
    await overlayKey?.currentState?.reverse();
    overlayEntry?.remove();
    overlayEntry = null;
    origin = null;
    scaleStartPosition = null;
    reversing = false;
    setState(() {
      zooming = false;
    });
  }
}

class PinchZoomOverlayImage extends StatefulWidget {
  final Key? key;
  final Offset origin;
  final double width;
  final double height;
  final Widget image;

  PinchZoomOverlayImage({
    this.key,
    required this.origin,
    required this.width,
    required this.height,
    required this.image,
  }) : super(key: key);

  @override
  PinchZoomOverlayImageState createState() => PinchZoomOverlayImageState();
}

class PinchZoomOverlayImageState extends State<PinchZoomOverlayImage>
    with TickerProviderStateMixin {
  AnimationController? reverseAnimationController;
  Offset? position;
  double scale = 1.0;

  @override
  void initState() {
    super.initState();
    this.position = widget.origin;
  }

  @override
  void dispose() {
    reverseAnimationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Opacity(
          opacity: ((scale - 1.0) /
                  ((MediaQuery.of(context).size.height / widget.height) - 1.0))
              .clamp(0.0, 1.0),
          child: Container(
            color: Colors.black,
          ),
        ),
        Positioned(
          top: position!.dy,
          left: position!.dx,
          width: widget.width,
          height: widget.height,
          child: Transform.scale(
            scale: scale,
            child: widget.image,
          ),
        ),
      ],
    );
  }

  void updatePosition(Offset newPosition) {
    setState(() {
      position = newPosition;
    });
  }

  void updateScale(double newScale) {
    setState(() {
      scale = newScale;
    });
  }

  TickerFuture reverse() {
    Offset origin = widget.origin;
    Offset reverseStartPosition = position!;
    double reverseStartScale = scale;

    reverseAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    )..addListener(() {
        setState(() {
          position = Offset.lerp(
            reverseStartPosition,
            origin,
            Curves.easeInOut.transform(reverseAnimationController!.value),
          );

          scale = lerpDouble(
            reverseStartScale!,
            1.0,
            Curves.easeInOut.transform(reverseAnimationController!.value),
          )!;
        });
      });

    return reverseAnimationController!.forward(from: 0.0);
  }
}
