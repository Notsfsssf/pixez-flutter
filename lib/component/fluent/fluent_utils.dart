import 'package:fluent_ui/fluent_ui.dart';
import 'package:pixez/i18n.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

CustomHeader buildCustomHeader() => CustomHeader(
    builder: (context, mode) {
      Widget body;
      if (mode == RefreshStatus.idle) {
        body = Text("refresh");
      } else if (mode == RefreshStatus.refreshing) {
        body = ProgressRing();
      } else if (mode == RefreshStatus.failed) {
        body = Text(I18n.of(context).loading_failed_retry_message);
      } else {
        body = Text("Success");
      }
      return Container(
        height: 55.0,
        child: Center(child: body),
      );
    },
  );
