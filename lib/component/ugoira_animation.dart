import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pixez/models/ugoira_metadata_response.dart';

class UgoiraAnima extends StatefulWidget {
  final List<FileSystemEntity> imageCaches;
  final List<Frame> frames;

  UgoiraAnima(this.imageCaches, this.frames, {Key key}) : super(key: key);

  @override
  _UgoiraAnimaState createState() => _UgoiraAnimaState();
}

class _UgoiraAnimaState extends State<UgoiraAnima> {
  bool _disposed;
  Duration _duration;
  int _imageIndex;
  FileSystemEntity _container;

  @override
  void initState() {
    super.initState();
    _disposed = false;
    _duration = Duration(milliseconds: widget.frames.first.delay);
    _imageIndex = 0;
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
      _container = widget.imageCaches[_imageIndex];
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
    return Container(
      child: _container != null ? Image.file(_container) : Text("load"),
    );
  }
}

// 帧动画Image
class FrameAnimationImage extends StatefulWidget {
  final List<FileSystemEntity> _assetList;
  final double width;
  final double height;
  int interval = 200;

  FrameAnimationImage(this._assetList,
      {this.width, this.height, this.interval});

  @override
  State<StatefulWidget> createState() {
    return _FrameAnimationImageState();
  }
}

class _FrameAnimationImageState extends State<FrameAnimationImage>
    with SingleTickerProviderStateMixin {
  // 动画控制
  Animation<double> _animation;
  AnimationController _controller;
  int interval = 200;

  @override
  void initState() {
    super.initState();

    if (widget.interval != null) {
      interval = widget.interval;
    }
    final int imageCount = widget._assetList.length;
    final int maxTime = interval * imageCount;

    // 启动动画controller
    _controller = new AnimationController(
        duration: Duration(milliseconds: maxTime), vsync: this);
    _controller.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        _controller.forward(from: 0.0); // 完成后重新开始
      }
    });

    _animation = new Tween<double>(begin: 0, end: imageCount.toDouble())
        .animate(_controller)
          ..addListener(() {
            setState(() {
              // the state that has changed here is the animation object’s value
            });
          });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int ix = _animation.value.floor() % widget._assetList.length;

    List<Widget> images = [];
    // 把所有图片都加载进内容，否则每一帧加载时会卡顿
    for (int i = 0; i < widget._assetList.length; ++i) {
      if (i != ix) {
        images.add(Image.file(
          File(widget._assetList[i].path),
          width: 0,
          height: 0,
        ));
      }
    }

    images.add(Image.file(
      File(widget._assetList[ix].path),
      width: widget.width,
      height: widget.height,
    ));

    return Stack(alignment: AlignmentDirectional.center, children: images);
  }
}
