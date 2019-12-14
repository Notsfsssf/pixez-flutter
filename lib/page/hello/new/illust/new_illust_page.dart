import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pixez/component/illust_card.dart';
import 'package:pixez/page/hello/new/illust/bloc/bloc.dart';

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
  final String restrict;

  const NewIllustPage({Key key, this.restrict}) : super(key: key);
  @override
  _NewIllustPageState createState() => _NewIllustPageState();
}

class _NewIllustPageState extends State<NewIllustPage> {
  Completer<void> _refreshCompleter, _loadCompleter;
  NewIllustBloc _bloc;
  @override
  void initState() {
    super.initState();
    _refreshCompleter = Completer<void>();
    _loadCompleter = Completer<void>();
  
  }

  @override
  void dispose() {
    super.dispose();
    _bloc.close();
  }

  @override
  Widget build(BuildContext context) {
      _bloc = NewIllustBloc()..add(FetchEvent(widget.restrict));
    return BlocListener<NewIllustBloc, NewIllustState>(
      bloc: _bloc,
      listener: (context, state) {
        if (state is DataNewIllustState) {
          _loadCompleter?.complete();
          _loadCompleter = Completer();
          _refreshCompleter?.complete();
          _refreshCompleter = Completer();
        }
      },
      child: BlocBuilder<NewIllustBloc, NewIllustState>(
          bloc: _bloc,
          builder: (context, state) {
            if (state is DataNewIllustState)
              return _buildEasyRefresh(state, context);
            else
              return Center(
                child: CircularProgressIndicator(),
              );
          }),
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
        _bloc.add(FetchEvent(widget.restrict));
        return _refreshCompleter.future;
      },
      onLoad: () async {
        _bloc.add(LoadMoreEvent(state.nextUrl, state.illusts));
        return _loadCompleter.future;
      },
    );
  }
}
