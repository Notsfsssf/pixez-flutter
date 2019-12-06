import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pixez/component/illust_card.dart';
import 'package:pixez/page/hello/new/new_illust/bloc/bloc.dart';

class DrawTriangle extends CustomPainter {
  Paint _paint;
  final Color color;

  DrawTriangle(this.color) {
    _paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
  }

  @override
  void paint(Canvas canvas, Size size) {
    var path = Path();
    path.moveTo(size.width, 0);
    path.lineTo(0, 0);
    path.lineTo(size.height, size.width);
    path.close();
    canvas.drawPath(path, _paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class NewIllustPage extends StatefulWidget {
  @override
  _NewIllustPageState createState() => _NewIllustPageState();
}

class _NewIllustPageState extends State<NewIllustPage> {
  Completer<void> _refreshCompleter, _loadCompleter;

  @override
  void initState() {
    super.initState();
    _refreshCompleter = Completer<void>();
    _loadCompleter = Completer<void>();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      builder: (context) => NewIllustBloc()..add(FetchEvent()),
      child: BlocListener<NewIllustBloc, NewIllustState>(
          listener: (context, state) {
            if (state is DataNewIllustState) {
              _loadCompleter?.complete();
              _loadCompleter = Completer();
              _refreshCompleter?.complete();
              _refreshCompleter = Completer();
            }
          },
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              BlocBuilder<NewIllustBloc, NewIllustState>(
                  builder: (context, state) {
                if (state is DataNewIllustState)
                  return _buildEasyRefresh(state, context);
                else
                  return Center(
                    child: CircularProgressIndicator(),
                  );
              }),
              Align(
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: CustomPaint(
                    size: Size(20, 20),
                    painter: DrawTriangle(Colors.white),
                  ),
                ),
                alignment: Alignment.topRight,
              )
            ],
          )),
    );
  }

  EasyRefresh _buildEasyRefresh(
      DataNewIllustState state, BuildContext context) {
    return EasyRefresh(
      child: StaggeredGridView.countBuilder(
        crossAxisCount: 2,
        itemCount: state.illusts.length,
        itemBuilder: (context, index) {
          return IllustCard(state.illusts[index]);
        },
        staggeredTileBuilder: (int index) => StaggeredTile.fit(1),
      ),
      onRefresh: () async {
        BlocProvider.of<NewIllustBloc>(context).add(FetchEvent());
        return _refreshCompleter.future;
      },
      onLoad: () async {
        BlocProvider.of<NewIllustBloc>(context)
            .add(LoadMoreEvent(state.nextUrl, state.illusts));
        return _loadCompleter.future;
      },
    );
  }
}
