import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/main.dart';

class SingleInstancePlugin {
  static final platform = const EventChannel("com.perol.dev/single_instance");
  static bool _isInitialized = false;

  // 这个函数是确保同一时间有且只有一个Pixez实例存在的
  //
  // 它需要将其他实例的命令行参数转发给第一个实例
  // 然后结束自己的进程
  static void initialize({Function()? callback}) {
    if (_isInitialized) throw Exception('ReInitialized');
    platform.receiveBroadcastStream().listen(
      (event) {
        final args = event.toString().split('\n');
        debugPrint("从另一实例接收到的参数: $args");
        _argsParser(args, callback: callback);
      },
    );
    _isInitialized = true;
  }

  /// 解析命令行参数字符串
  static void _argsParser(List<String> args, {Function()? callback}) async {
    if (args.length < 1) return;

    final uri = Uri.tryParse(args[0]);
    if (uri != null) {
      debugPrint("::_argsParser(): 合法的Uri: \"${uri}\"");

      if (callback != null) callback();
      Leader.pushWithUri(routeObserver.navigator!.context, uri);
    }
  }
}
