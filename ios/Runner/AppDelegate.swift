import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let batteryChannel = FlutterMethodChannel(name: "samples.flutter.dev/battery",
                                              binaryMessenger: controller.binaryMessenger)
    batteryChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
        guard call.method == "getBatteryLevel" else {
          result(FlutterMethodNotImplemented)
          return
        }
        self.receiveBatteryLevel(result: result)
  
    })
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    private func receiveBatteryLevel(result: FlutterResult) {
      let secondVC = UIStoryboard(name: "Spotlight", bundle: nil).instantiateViewController(withIdentifier: "spotlight") as UIViewController
      self.window.rootViewController?.present(secondVC, animated: true, completion: nil)
        result(Int(1))
    }
}
