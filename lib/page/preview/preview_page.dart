import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class PreviewPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: EasyRefresh(
        child: StaggeredGridView.countBuilder(
          crossAxisCount: 3,
          itemBuilder: (BuildContext context, int index) {
            return Card(
              child: Container(),
            );
          },
          staggeredTileBuilder: (int index) => StaggeredTile.fit(1),
        ),
      ),
    );
  }
}
