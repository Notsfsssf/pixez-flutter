import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pixez/document_plugin.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/fluent/page/hello/setting/save_format_page.dart';

part 'platform_page.windows.dart';

class PlatformPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    if (Platform.isWindows) return _PlatformPageStateWindow();
    throw UnimplementedError();
  }
}
