//
//  WidgetkitPlugin.swift
//  Runner
//
//  Created by  perol on 2021/3/28.
//

import Foundation

public class WidgetkitPlugin {
  public  static func bind(controller : FlutterViewController){
        let batteryChannel = FlutterMethodChannel(name: "com.perol.dev/widgetkit",
                                                  binaryMessenger: controller.binaryMessenger)
        batteryChannel.setMethodCallHandler({
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            if call.method == "getBatteryLevel"  {
                notify()
                result(nil)
                return
            }
            
        })
    }
    
    private static func notify()  {
        if let data =  UserDefaults(suiteName: "com.perol.pixez")!.string(forKey:  "flutter.app_widget_data") {
            let host = UserDefaults(suiteName: "com.perol.pixez")!.string(forKey: "flutter.picture_source") ?? "i.pximg.net"
            let time = UserDefaults(suiteName: "com.perol.pixez")!.integer(forKey: "flutter.app_widget_time")
            let userDefault = UserDefaults(suiteName: "com.perol.pixez")
            userDefault?.setValue(host, forKey: "widgetkit.picture_source")
            userDefault?.setValue(data, forKey: "widgetkit.app_widget_data")
            userDefault?.setValue(time, forKey: "widgetkit.app_widget_time")
        }
    }
}
