/// No-op stub matching the wakelock_plus API used by chewie.
class WakelockPlus {
  static Future<void> enable() => toggle(enable: true);

  static Future<void> disable() => toggle(enable: false);

  static Future<void> toggle({required bool enable}) async {}

  static Future<bool> get enabled async => false;
}
