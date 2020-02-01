import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pixez/models/illust.dart';
import 'package:pixez/models/ugoira_metadata_response.dart';

/*class MyPainter extends CustomPainter {
  final List<ui.Image> assetList;
  final List<Frame> frames;
  Paint paint1 = Paint();


  MyPainter(this.assetList, this.frames);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawImage(
        assetList.first, Offset(0, 0), paint1);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return oldDelegate!=this;
  }
}

class UgoiraAnima extends StatefulWidget {
  final List<FileSystemEntity> assetList;

  final List<Frame> frames;

  const UgoiraAnima(
      {Key key,
        @required this.assetList,

        @required this.frames})
      : super(key: key);

  @override
  _UgoiraAnimaState createState() => _UgoiraAnimaState();
}

class _UgoiraAnimaState extends State<UgoiraAnima> {
  List<ui.Image> assetList=[];
  bool imok=false;
  @override
  void initState() {
    super.initState();
    loading();
  }
  Future<ui.Image> _loadImage(File file) async {
    final data = await file.readAsBytes();
    return await decodeImageFromList(data);
  }
  double width;
  double height;
  @override
  Widget build(BuildContext context) {
    if(imok)
      return FittedBox(
        child: SizedBox(
          width:width,
          height:height,
          child: CustomPaint(
            painter: MyPainter(assetList, widget.frames),
          ),
        ),
      );
    else return Container(
      height: 80,
    );
  }

  void loading() async{
    for (var i in widget.assetList){
      var image = await _loadImage(File(i.path));
      width = image.width.toDouble();
      height =image.height.toDouble();
      assetList.add(image);

    }
    setState(() {
      imok=true;
    });
  }
}*/

// 帧动画Image
class FrameAnimationImage extends StatefulWidget {
  final List<FileSystemEntity> _assetList;
  final double width;
  final double height;
  int interval = 200;
final Illusts illusts;
  FrameAnimationImage(this._assetList,
      {this.width, this.height, this.interval,this.illusts,});

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
    double width,height;
    for (int i = 0; i < widget._assetList.length; ++i) {
      if (i != ix) {
     var image=   Image.file(
          File(widget._assetList[i].path),
       width: widget.illusts.width.toDouble(),
       height:widget.illusts.height.toDouble() ,
        );
  if(i==0){
    width = image.width;
    height =image.height;
  }
        images.add(image);
      }
    }

    images.add(Image.file(
      File(widget._assetList[ix].path),
      fit: BoxFit.fitWidth,
    ));

    return FittedBox(child: SizedBox(child: Stack( children: images),width: width,height: height,));
  }
}
