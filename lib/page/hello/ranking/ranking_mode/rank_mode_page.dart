import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:pixez/lighting/lighting_page.dart';
import 'package:pixez/network/api_client.dart';

class RankModePage extends StatefulWidget {
  final String mode, date;

  const RankModePage({Key key, this.mode, this.date}) : super(key: key);

  @override
  _RankModePageState createState() => _RankModePageState();
}

class _RankModePageState extends State<RankModePage>
    with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return LightingList(
      source: () => RepositoryProvider.of<ApiClient>(context).getIllustRanking(
        widget.mode,
        widget.date,
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
