import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pixez/component/illust_card.dart';
import 'package:pixez/page/user/works/bloc.dart';

class WorksPage extends StatefulWidget {
  final int id;

  const WorksPage({Key key, this.id}) : super(key: key);

  @override
  _WorksPageState createState() => _WorksPageState();
}

class _WorksPageState extends State<WorksPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      builder: (context) =>
          WorksBloc()..add(FetchWorksEvent(widget.id, "illust")),
      child: BlocBuilder<WorksBloc, WorksState>(
        builder: (context, state) {
          if (state is DataWorksState)
            return EasyRefresh(
              child: StaggeredGridView.countBuilder(
                crossAxisCount: 2,
                itemCount: state.illusts.length,
                itemBuilder: (context, index) {
                  return IllustCard(state.illusts[index]);
                },
                staggeredTileBuilder: (int index) => StaggeredTile.fit(1),
              ),
              onLoad: () async {
                BlocProvider.of<WorksBloc>(context)
                    .add(LoadMoreEvent(state.nextUrl, state.illusts));
              },
            );
          return Container();
        },
      ),
    );
  }
}
