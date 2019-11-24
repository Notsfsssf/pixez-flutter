import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pixez/component/illust_card.dart';
import 'package:pixez/page/hello/recom/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loadmore/loadmore.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
class ReComPage extends StatefulWidget {
  @override
  _ReComPageState createState() => _ReComPageState();
}

class _ReComPageState extends State<ReComPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      builder: (context) => RecomBloc()..add(FetchEvent()),
      child: BlocBuilder<RecomBloc, RecomState>(
        builder: (context, state) {
          if (state is DataRecomState)
            return EasyRefresh(
              child: StaggeredGridView.countBuilder(
                crossAxisCount: 2,
                itemCount: state.illusts.length,
                itemBuilder: (context, index) {
                  return IllustCard(state.illusts[index]);
                },
                staggeredTileBuilder: (int index) => StaggeredTile.fit(1),
              ),
              onLoad: () async{
                BlocProvider.of<RecomBloc>(context).add(LoadMoreEvent(state.nextUrl,state.illusts));
              },
            );
          return Container();
        },
      ),
    );
  }
}
