import 'package:meta/meta.dart';
import 'package:rhttp/src/model/request.dart';

const _minNotifyInterval = 20; // 1000 / 20 = 50 FPS

/// A notifier for progress with rate limiting.
@internal
class ProgressNotifier {
  final ProgressCallback onProgress;
  int lastNotify = 0;
  int bytes = 0;

  ProgressNotifier(this.onProgress);

  void notify(int newBytes, int total) {
    bytes += newBytes;
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - lastNotify >= _minNotifyInterval) {
      lastNotify = now;
      onProgress(bytes, total);
    }
  }

  void notifyDone(int total) {
    onProgress(total, total);
  }
}
