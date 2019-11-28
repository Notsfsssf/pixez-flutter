import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pixez/component/illust_card.dart';
import 'package:pixez/page/user/bookmark/bloc.dart';

class BookmarkPage extends StatefulWidget {
  final int id;

  const BookmarkPage({Key key, this.id}) : super(key: key);

  @override
  _BookmarkPageState createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      builder: (context) =>
          BookmarkBloc()..add(FetchBookmarkEvent(widget.id, "illust")),
      child: BlocBuilder<BookmarkBloc, BookmarkState>(
        builder: (context, state) {
          if (state is DataBookmarkState)
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
                BlocProvider.of<BookmarkBloc>(context)
                    .add(LoadMoreEvent(state.nextUrl, state.illusts));
              },
            );
          return Container();
        },
      ),
    );
  }
}
