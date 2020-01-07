import 'package:flutter/material.dart';
import 'package:pixez/models/ugoira_metadata_response.dart';

class UgoiraAnima extends StatefulWidget {
  final Map<int, Image> imageCaches;
  final Color backColor;
  final List<Frame> frames;
  final double width;
  final double height;

  UgoiraAnima(
    this.imageCaches,
    this.frames,
    this.width,
    this.height, {
    Key key,
    this.backColor,
  }) : super(key: key);

  @override
  _UgoiraAnimaState createState() => _UgoiraAnimaState();
}

class _UgoiraAnimaState extends State<UgoiraAnima> {
  bool _disposed;
  Duration _duration;
  int _imageIndex;
  Container _container;

  @override
  void initState() {
    super.initState();
    _disposed = false;
    _duration = Duration(milliseconds: widget.frames.first.delay);
    _imageIndex = 0;
    _container = Container(
      height: widget.height,
      width: widget.width,
      color: widget.backColor,
    );
    _updateImage();
  }

  void _updateImage() {
    if (_disposed || widget.imageCaches.isEmpty) {
      return;
    }

    setState(() {
      if (_imageIndex >= widget.imageCaches.length) {
        _imageIndex = 0;
      }
      _container = Container(
        child: widget.imageCaches[_imageIndex],
        height: widget.height,
        width: widget.width,
        color: widget.backColor,
      );
      _imageIndex++;
    });
    _duration = Duration(
        milliseconds: _imageIndex < widget.frames.length
            ? widget.frames[_imageIndex].delay
            : widget.frames.first.delay);
    Future.delayed(_duration, () {
      _updateImage();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _disposed = true;
    widget.imageCaches.clear();
  }

  @override
  Widget build(BuildContext context) {
    return _container;
  }
}
