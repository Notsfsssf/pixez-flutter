import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixez/generated/l10n.dart';
import 'package:pixez/lighting/lighting_page.dart';
import 'package:pixez/lighting/lighting_store.dart';
import 'package:pixez/network/api_client.dart';

class WorksPage extends StatefulWidget {
  final int id;

  const WorksPage({Key key, @required this.id}) : super(key: key);

  @override
  _WorksPageState createState() => _WorksPageState();
}

class _WorksPageState extends State<WorksPage>
 {
  FutureGet futureGet;

  @override
  void initState() {
    futureGet = () => RepositoryProvider.of<ApiClient>(context)
        .getUserIllusts(widget.id, 'illust');
    super.initState();
  }

  String now = 'illust';

  @override
  Widget build(BuildContext context) {

    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        _buildHeader(),
        Expanded(
          child: LightingList(
            source: futureGet,
          ),
        )
      ],
    );
  }

  Widget _buildHeader() {
    return Container(

      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
        child: Wrap(
          spacing: 8.0,
          alignment: WrapAlignment.center,
          children: <Widget>[
            ActionChip(
              backgroundColor: now == 'illust'
                  ? Theme.of(context).accentColor
                  : Colors.transparent,
              label: Text(I18n.of(context).Illust,style: TextStyle(
                color: now == 'illust'?Colors.white:Theme.of(context).textTheme.headline6.color
              ),),
              onPressed: () {
                setState(() {
                  futureGet = () => RepositoryProvider.of<ApiClient>(context)
                      .getUserIllusts(widget.id, 'illust');
                  now = 'illust';
                });
              },
            ),
            ActionChip(
              label: Text(I18n.of(context).Manga,style: TextStyle(
                color: now == 'manga'?Colors.white:Theme.of(context).textTheme.headline6.color
              ),),
              onPressed: () {
                setState(() {
                  futureGet = () => RepositoryProvider.of<ApiClient>(context)
                      .getUserIllusts(widget.id, 'manga');
                  now = 'manga';
                });
              },
              backgroundColor: now != 'illust'
                  ? Theme.of(context).accentColor
                  : Colors.transparent,
            )
          ],
        ),
      ),
    );
  }

}
