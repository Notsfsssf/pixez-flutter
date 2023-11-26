import 'package:easy_refresh/easy_refresh.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:pixez/i18n.dart';

class PixezDefault {
  static Header header(BuildContext context) {
    return ClassicHeader();
  }

  static Footer footer(BuildContext context) {
    return ClassicFooter(
        failedText: I18n.of(context).loading_failed_retry_message,
        processedText: I18n.of(context).successed);
  }
}
